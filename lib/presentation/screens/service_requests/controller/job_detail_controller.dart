import 'dart:async';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/domain/repos/job_repository.dart';

class JobDetailController extends GetxController {
  final String jobId;
  final JobRepository _repo;

  JobDetailController({required this.jobId, JobRepository? repo})
      : _repo = repo ?? JobRepository();

  // ── State ──────────────────────────────────────────────────────────
  final Rxn<JobRequestModel> job = Rxn<JobRequestModel>();
  final RxBool isLoading = true.obs;
  final RxBool isCancelling = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<JobRequestModel?>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _repo.watchJob(jobId).listen(
          (j) {
        job.value = j;
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  Future<void> cancelJob(String reason) async {
    isCancelling.value = true;
    try {
      // Write cancellation reason then update status
      await _repo.cancelJob(jobId);
      // Optionally store reason — extend repo if needed
    } catch (e) {
      Get.snackbar('Error', 'Could not cancel job: $e');
    } finally {
      isCancelling.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ── Status helpers used by the UI ─────────────────────────────────

  /// Maps JobStatus → the internal string key the detail screen uses
  static String statusKey(JobStatus s) {
    switch (s) {
      case JobStatus.newRequest:  return 'new';
      case JobStatus.pending:     return 'pending';
      case JobStatus.underReview: return 'under_review';
      case JobStatus.accepted:    return 'accepted';
      case JobStatus.inProgress:  return 'inprogress';
      case JobStatus.ongoing:     return 'inprogress'; // treated same as inProgress
      case JobStatus.completed:   return 'completed';
      case JobStatus.cancelled:   return 'cancelled_by_me';
    }
  }

  static String statusText(String key) {
    switch (key) {
      case 'new':            return 'New';
      case 'under_review':   return 'Under Review';
      case 'accepted':       return 'Accepted';
      case 'pending':        return 'Pending';
      case 'inprogress':     return 'In Progress';
      case 'completed':      return 'Completed';
      case 'cancelled_by_me':
      case 'cancelled_by_sp':return 'Cancelled';
      default:               return '';
    }
  }

  // ── Date / time formatting ─────────────────────────────────────────
  static String formatDate(DateTime dt) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  static String formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}