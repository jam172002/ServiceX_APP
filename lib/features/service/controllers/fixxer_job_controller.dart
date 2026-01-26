import 'package:get/get.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';

class FixxerJobController extends GetxController {
  final jobStatus = FixxerJobStatus.newRequest.obs;

  final quotedPrice = ''.obs;
  final quotedDeadline = Rxn<DateTime>();

  void sendQuote(String price, DateTime deadline) {
    quotedPrice.value = price;
    quotedDeadline.value = deadline;
    jobStatus.value = FixxerJobStatus.quoteSent;
  }

  void editQuote(String price, DateTime deadline) {
    quotedPrice.value = price;
    quotedDeadline.value = deadline;
  }

  void startJob() {
    jobStatus.value = FixxerJobStatus.jobStarted;
  }

  void cancelJob() {
    Get.back();
    Get.snackbar(
      'Cancelled',
      'Job has been cancelled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
