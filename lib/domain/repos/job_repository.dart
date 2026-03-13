import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../enums/app_enums.dart';
import '../models/job_request_model.dart';
import '../models/quote_model.dart';

class JobRepository {
  final FirebaseFirestore _db;
  JobRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.jobRequests);

  // ── Quotes subcollection ref ──────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _quotesCol(String jobId) =>
      _col.doc(jobId).collection('quotes');

  // ── Job CRUD ──────────────────────────────────────────────────────────────

  Future<String> createJob(JobRequestModel job) async {
    final ref = job.id.isEmpty ? _col.doc() : _col.doc(job.id);
    await ref.set(job.copyWith().toJson()..['id'] = ref.id,
        SetOptions(merge: true));
    return ref.id;
  }

  Future<JobRequestModel?> getJob(String jobId) async {
    final snap = await _col.doc(jobId).get();
    if (!snap.exists) return null;
    final data = snap.data() ?? {};
    data['id'] = snap.id;
    return JobRequestModel.fromJson(data);
  }

  Stream<JobRequestModel?> watchJob(String jobId) {
    return _col.doc(jobId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? {};
      data['id'] = snap.id;
      return JobRequestModel.fromJson(data);
    });
  }

  Stream<List<JobRequestModel>> watchUserJobs(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return JobRequestModel.fromJson(data);
    }).toList());
  }

  Stream<List<JobRequestModel>> watchProviderJobs(String providerId) {
    return _col
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return JobRequestModel.fromJson(data);
    }).toList());
  }

  Stream<List<JobRequestModel>> watchOpenJobs() {
    return _col
        .where('providerId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return JobRequestModel.fromJson(data);
    }).toList());
  }

  Future<void> updateStatus(String jobId, JobStatus status) async {
    await _col.doc(jobId).set(
        {'status': jobStatusToString(status)}, SetOptions(merge: true));
  }

  Future<void> cancelJob(String jobId) async {
    await updateStatus(jobId, JobStatus.cancelled);
  }

  Future<void> assignProvider(String jobId, String providerId) async {
    await _col.doc(jobId).set({
      'providerId': providerId,
      'status': jobStatusToString(JobStatus.accepted),
    }, SetOptions(merge: true));
  }

  // ── Quotes ────────────────────────────────────────────────────────────────

  /// Real-time stream of all quotes for a job, ordered by createdAt ascending.
  Stream<List<QuoteModel>> watchQuotes(String jobId) {
    return _quotesCol(jobId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((q) => q.docs
        .map((d) => QuoteModel.fromDoc(
        d as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  /// One-shot fetch of all quotes for a job.
  Future<List<QuoteModel>> getQuotes(String jobId) async {
    final snap = await _quotesCol(jobId)
        .orderBy('createdAt', descending: false)
        .get();
    return snap.docs
        .map((d) =>
        QuoteModel.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  /// Accept a quote — updates quote status + job status to accepted,
  /// and rejects all other pending quotes for this job.
  Future<void> acceptQuote(String jobId, String fixxerId) async {
    final batch = _db.batch();

    // Update accepted quote
    batch.set(
      _quotesCol(jobId).doc(fixxerId),
      {'status': 'accepted', 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    // Update job status to accepted and set the providerId
    batch.set(
      _col.doc(jobId),
      {
        'status':     jobStatusToString(JobStatus.accepted),
        'providerId': fixxerId,
        'updatedAt':  FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    // Reject all other pending quotes (outside batch — needs query first)
    final others = await _quotesCol(jobId)
        .where('status', isEqualTo: 'pending')
        .get();
    final rejectBatch = _db.batch();
    for (final doc in others.docs) {
      if (doc.id != fixxerId) {
        rejectBatch.set(
          doc.reference,
          {'status': 'rejected', 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      }
    }
    await rejectBatch.commit();
  }

  /// Reject a single quote.
  Future<void> rejectQuote(String jobId, String fixxerId) async {
    await _quotesCol(jobId).doc(fixxerId).set(
        {'status': 'rejected', 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }

  /// Count of quotes for a job (for badge display).
  Future<int> getQuoteCount(String jobId) async {
    final snap = await _quotesCol(jobId).count().get();
    return snap.count ?? 0;
  }

  /// Stream of quote count — for live badge on job card.
  Stream<int> watchQuoteCount(String jobId) {
    return _quotesCol(jobId).snapshots().map((s) => s.size);
  }
}