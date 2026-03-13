const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// ── HTTP endpoint ──────────────────────────────────────────────────────────
// Called directly from the Flutter app via sendMessageNotification()

exports.sendChatNotification = onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const { token, title, body, data } = req.body;

  if (!token || !title || !body) {
    res.status(400).json({ error: "token, title, and body are required." });
    return;
  }

  try {
    const result = await admin.messaging().send({
      token,
      notification: { title, body },
      data: {
        type: data?.type ?? "chat_message",
        conversationId: data?.conversationId ?? "",
        senderName: data?.senderName ?? title,
        senderAvatar: data?.senderAvatar ?? "",
      },
      android: {
        priority: "high",
        notification: { channelId: "chat_channel", sound: "default" },
      },
      apns: {
        payload: { aps: { sound: "default", badge: 1 } },
      },
    });

    res.status(200).json({ success: true, messageId: result });
  } catch (error) {
    console.error("FCM send error:", error);
    res.status(500).json({ error: error.message });
  }
});

// ── Firestore trigger: new chat message ───────────────────────────────────

exports.onNewChatMessage = onDocumentCreated(
  "conversations/{convId}/messages/{msgId}",
  async (event) => {
    const msg = event.data?.data();
    if (!msg) return;

    const { senderId, receiverId, text, type } = msg;
    if (!receiverId) return;

    const convSnap = await admin
      .firestore()
      .collection("conversations")
      .doc(event.params.convId)
      .get();

    if (!convSnap.exists) return;

    const conv = convSnap.data();
    const recipientToken = conv.fcmTokens?.[receiverId];
    const senderName = conv.participantNames?.[senderId] ?? "Someone";
    const senderAvatar = conv.participantAvatars?.[senderId] ?? "";

    if (!recipientToken) return;

    const preview =
      type === "image" ? "📷 Photo" : type === "video" ? "🎥 Video" : text;

    try {
      await admin.messaging().send({
        token: recipientToken,
        notification: { title: senderName, body: preview },
        data: {
          type: "chat_message",
          conversationId: event.params.convId,
          senderName,
          senderAvatar,
        },
        android: {
          priority: "high",
          notification: { channelId: "chat_channel", sound: "default" },
        },
        apns: {
          payload: { aps: { sound: "default", badge: 1 } },
        },
      });
    } catch (err) {
      console.error("FCM chat trigger error:", err);
    }
  }
);

// ── Firestore trigger: new job request ────────────────────────────────────
// Fires when a new document is created in `job_requests`.
// Finds all fixxers whose mainCategory matches the job's categoryId
// AND whose subCategories list contains the job's subcategoryId.
// Sends an FCM push notification to each matching fixxer.

exports.onNewJobRequest = onDocumentCreated(
  "job_requests/{jobId}",
  async (event) => {
    const job = event.data?.data();
    if (!job) return;

    const jobId     = event.params.jobId;
    const categoryId    = job.categoryId    ?? "";
    const subcategoryId = job.subcategoryId ?? "";
    const categoryName    = job.categoryName    ?? "New Job";
    const subcategoryName = job.subcategoryName ?? "";
    const address   = job.address ?? "Unknown location";
    const budgetMin = job.budgetMin ?? 0;
    const budgetMax = job.budgetMax ?? 0;
    const isOpenForAll  = job.isOpenForAll ?? true;
    const providerId    = job.providerId   ?? null;

    // ── Build notification body ──────────────────────────────────
    const serviceLabel = subcategoryName || categoryName;
    const notifTitle   = `New Job: ${serviceLabel}`;
    const notifBody    = `\$${budgetMin}–\$${budgetMax} · ${address}`;

    if (isOpenForAll) {
      // ── Open job: notify ALL fixxers whose mainCategory matches
      //    AND who have the subcategory in their subCategories list ──

      let query = admin.firestore()
        .collection("fixxers")
        .where("mainCategory", "==", categoryId);

      // Only filter by subcategory if one was specified on the job
      if (subcategoryId) {
        query = query.where("subCategories", "array-contains", subcategoryId);
      }

      const fixxersSnap = await query.get();

      if (fixxersSnap.empty) {
        console.log(`No matching fixxers for categoryId=${categoryId}`);
        return;
      }

      // Collect all FCM tokens (fixxers store their token in `fcmToken` field)
      const tokens = [];
      fixxersSnap.forEach((doc) => {
        const token = doc.data().fcmToken;
        if (token && typeof token === "string" && token.trim().length > 0) {
          tokens.push(token);
        }
      });

      if (tokens.length === 0) {
        console.log("Matching fixxers found but none have an FCM token.");
        return;
      }

      // Send in batches of 500 (FCM multicast limit)
      const chunks = chunkArray(tokens, 500);
      for (const chunk of chunks) {
        try {
          const response = await admin.messaging().sendEachForMulticast({
            tokens: chunk,
            notification: { title: notifTitle, body: notifBody },
            data: {
              type:           "new_job",
              jobId:          jobId,
              categoryId:     categoryId,
              subcategoryId:  subcategoryId,
              categoryName:   categoryName,
              subcategoryName: subcategoryName,
              address:        address,
              budgetMin:      String(budgetMin),
              budgetMax:      String(budgetMax),
            },
            android: {
              priority: "high",
              notification: { channelId: "jobs_channel", sound: "default" },
            },
            apns: {
              payload: { aps: { sound: "default", badge: 1 } },
            },
          });
          console.log(
            `Job notif batch sent: ${response.successCount} success, ` +
            `${response.failureCount} failed`
          );
        } catch (err) {
          console.error("FCM job multicast error:", err);
        }
      }

    } else {
      // ── Direct job: notify only the specific provider ────────────
      if (!providerId) return;

      const fixxerSnap = await admin.firestore()
        .collection("fixxers")
        .doc(providerId)
        .get();

      if (!fixxerSnap.exists) return;

      const token = fixxerSnap.data().fcmToken;
      if (!token) return;

      try {
        await admin.messaging().send({
          token,
          notification: { title: `Direct Job Request: ${serviceLabel}`, body: notifBody },
          data: {
            type:           "new_job",
            jobId:          jobId,
            categoryId:     categoryId,
            subcategoryId:  subcategoryId,
            categoryName:   categoryName,
            subcategoryName: subcategoryName,
            address:        address,
            budgetMin:      String(budgetMin),
            budgetMax:      String(budgetMax),
          },
          android: {
            priority: "high",
            notification: { channelId: "jobs_channel", sound: "default" },
          },
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        });
        console.log(`Direct job notification sent to providerId=${providerId}`);
      } catch (err) {
        console.error("FCM direct job error:", err);
      }
    }
  }
);

// ── Helper ────────────────────────────────────────────────────────────────

function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}