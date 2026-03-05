import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/domain/repos/job_repository.dart';

class JobRequestsController extends GetxController {
  final JobRepository _repo;
  JobRequestsController({JobRepository? repo})
      : _repo = repo ?? JobRepository();

  // ── State ──────────────────────────────────────────────────────────
  final RxList<JobRequestModel> allJobs = <JobRequestModel>[].obs;
  final RxString selectedStatus = 'All'.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<JobRequestModel>>? _sub;

  // ── Filter options shown in the tab bar ───────────────────────────
  static const List<String> filterLabels = [
    'All',
    'Pending',
    'Accepted',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  // ── Derived filtered list ─────────────────────────────────────────
  List<JobRequestModel> get filteredJobs {
    if (selectedStatus.value == 'All') return allJobs;
    final target = _labelToStatus(selectedStatus.value);
    if (target == null) return allJobs;
    return allJobs.where((j) => j.status == target).toList();
  }

  JobStatus? _labelToStatus(String label) {
    switch (label) {
      case 'Pending':     return JobStatus.pending;
      case 'Accepted':    return JobStatus.accepted;
      case 'In Progress': return JobStatus.inProgress;
      case 'Completed':   return JobStatus.completed;
      case 'Cancelled':   return JobStatus.cancelled;
      default:            return null;
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      error.value = 'Not logged in';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    _sub = _repo.watchUserJobs(uid).listen(
          (jobs) {
        allJobs.assignAll(jobs);
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  void setFilter(String status) => selectedStatus.value = status;

  /// Pull-to-refresh: cancel and restart the stream subscription.
  Future<void> refresh() async {
    await _sub?.cancel();
    _startListening();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ── Helpers for the card ──────────────────────────────────────────

  /// Human-readable status label
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

  /// Formatted budget string
  static String budgetLabel(int min, int max) => '\$$min - \$$max';

  /// Formatted date string from DateTime
  static String dateLabel(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  /// Formatted time string
  static String timeLabel(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}