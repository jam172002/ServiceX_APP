import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/domain/repos/job_repository.dart';

class JobController extends GetxController {
  final JobRepository _repo;
  JobController({JobRepository? repo}) : _repo = repo ?? JobRepository();

  final RxList<JobRequestModel> allJobs = <JobRequestModel>[].obs;
  final RxString selectedStatus         = 'All'.obs;
  final RxBool isLoading                = true.obs;
  final RxString error                  = ''.obs;

  StreamSubscription<List<JobRequestModel>>? _sub;

  // ── Four filter labels shown in the bottom sheet ──────────────────────────
  static const List<String> filterLabels = [
    'All',
    'Booked',
    'Cancelled',
    'Draft',
  ];

  // ── Filtered list ─────────────────────────────────────────────────────────
  List<JobRequestModel> get filteredJobs {
    switch (selectedStatus.value) {
      case 'Booked':
      // booked = accepted or inProgress or ongoing
        return allJobs.where((j) =>
        j.status == JobStatus.accepted ||
            j.status == JobStatus.inProgress ||
            j.status == JobStatus.ongoing).toList();
      case 'Cancelled':
        return allJobs.where((j) => j.status == JobStatus.cancelled).toList();
      case 'Draft':
      // draft = pending (submitted but not yet reviewed)
        return allJobs.where((j) =>
        j.status == JobStatus.pending ||
            j.status == JobStatus.newRequest).toList();
      default:
        return allJobs;
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      error.value     = 'Not logged in';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value     = '';

    _sub = _repo.watchUserJobs(uid).listen(
          (jobs) {
        allJobs.assignAll(jobs);
        isLoading.value = false;
      },
      onError: (e) {
        error.value     = e.toString();
        isLoading.value = false;
      },
    );
  }

  void setFilter(String status) => selectedStatus.value = status;

  Future<void> refresh() async {
    await _sub?.cancel();
    _startListening();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ── Helpers for card display ──────────────────────────────────────────────

  static String statusLabel(JobStatus s) {
    switch (s) {
      case JobStatus.newRequest:  return 'New';
      case JobStatus.pending:     return 'Pending';
      case JobStatus.underReview: return 'Under Review';
      case JobStatus.accepted:    return 'Accepted';
      case JobStatus.inProgress:  return 'In Progress';
      case JobStatus.ongoing:     return 'Ongoing';
      case JobStatus.completed:   return 'Completed';
      case JobStatus.cancelled:   return 'Cancelled';
    }
  }

  static String budgetLabel(int min, int max) => '\$$min - \$$max';

  static String dateLabel(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  static String timeLabel(DateTime dt) {
    final h      = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m      = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}