import 'dart:async';
import 'package:get/get.dart';
import '../../domain/repos/job_repository.dart';
import '../../domain/enums/app_enums.dart';
import '../../domain/models/job_request_model.dart';

class JobController extends GetxController {
  final JobRepository _repo;
  JobController({required JobRepository repo}) : _repo = repo;

  final RxList<JobRequestModel> userJobs = <JobRequestModel>[].obs;
  final RxList<JobRequestModel> providerJobs = <JobRequestModel>[].obs;
  final RxList<JobRequestModel> openJobs = <JobRequestModel>[].obs;

  StreamSubscription<List<JobRequestModel>>? _userSub;
  StreamSubscription<List<JobRequestModel>>? _providerSub;
  StreamSubscription<List<JobRequestModel>>? _openSub;

  void bindUserJobs(String userId) {
    _userSub?.cancel();
    _userSub = _repo.watchUserJobs(userId).listen(userJobs.assignAll);
  }

  void bindProviderJobs(String providerId) {
    _providerSub?.cancel();
    _providerSub = _repo
        .watchProviderJobs(providerId)
        .listen(providerJobs.assignAll);
  }

  void bindOpenJobs() {
    _openSub?.cancel();
    _openSub = _repo.watchOpenJobs().listen(openJobs.assignAll);
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _providerSub?.cancel();
    _openSub?.cancel();
    super.onClose();
  }

  Future<String> createJob(JobRequestModel job) => _repo.createJob(job);

  Future<void> cancelJob(String jobId) => _repo.cancelJob(jobId);

  Future<void> markCompleted(String jobId) =>
      _repo.updateStatus(jobId, JobStatus.completed);

  Future<void> markInProgress(String jobId) =>
      _repo.updateStatus(jobId, JobStatus.inProgress);

  Future<void> assignProvider(String jobId, String providerId) =>
      _repo.assignProvider(jobId, providerId);
}
