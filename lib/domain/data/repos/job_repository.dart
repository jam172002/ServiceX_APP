import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../enums/app_enums.dart';
import '../../models/job_request_model.dart';

class JobRepository {
  final FirebaseFirestore _db;
  JobRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.jobRequests);

  Future<String> createJob(JobRequestModel job) async {
    final doc = _col.doc(job.id.isEmpty ? null : job.id);
    final ref = job.id.isEmpty ? _col.doc() : doc;
    final jobToSave = job.copyWith();
    await ref.set(jobToSave.toJson()..['id'] = ref.id, SetOptions(merge: true));
    return ref.id;
  }

  Future<JobRequestModel?> getJob(String jobId) async {
    final snap = await _col.doc(jobId).get();
    if (!snap.exists) return null;
    final data = snap.data() ?? <String, dynamic>{};
    data['id'] = snap.id;
    return JobRequestModel.fromJson(data);
  }

  Stream<JobRequestModel?> watchJob(String jobId) {
    return _col.doc(jobId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? <String, dynamic>{};
      data['id'] = snap.id;
      return JobRequestModel.fromJson(data);
    });
  }

  Stream<List<JobRequestModel>> watchUserJobs(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return JobRequestModel.fromJson(data);
          }).toList();
        });
  }

  Stream<List<JobRequestModel>> watchProviderJobs(String providerId) {
    return _col
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return JobRequestModel.fromJson(data);
          }).toList();
        });
  }

  Stream<List<JobRequestModel>> watchOpenJobs() {
    return _col
        .where('providerId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return JobRequestModel.fromJson(data);
          }).toList();
        });
  }

  Future<void> updateStatus(String jobId, JobStatus status) async {
    await _col.doc(jobId).set({
      'status': enumToString(status),
    }, SetOptions(merge: true));
  }

  Future<void> cancelJob(String jobId) async {
    await updateStatus(jobId, JobStatus.cancelled);
  }

  Future<void> assignProvider(String jobId, String providerId) async {
    await _col.doc(jobId).set({
      'providerId': providerId,
      'status': enumToString(JobStatus.accepted),
    }, SetOptions(merge: true));
  }
}
