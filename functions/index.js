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

// ── Firestore trigger (recommended) ───────────────────────────────────────
// Fires automatically on the server whenever a new message is created.
// No Flutter code needed — just deploy and it works.

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
      console.error("FCM trigger error:", err);
    }
  }
);