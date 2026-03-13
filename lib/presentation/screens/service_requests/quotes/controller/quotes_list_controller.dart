import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/domain/models/quote_model.dart';
import 'package:servicex_client_app/domain/repos/job_repository.dart';

class QuotesController extends GetxController {
  final JobRequestModel job;
  final JobRepository _repo;

  QuotesController({required this.job, JobRepository? repo})
      : _repo = repo ?? JobRepository();

  final RxList<QuoteModel> quotes = <QuoteModel>[].obs;
  final RxBool isLoading          = true.obs;
  final RxString error            = ''.obs;
  final RxString acceptingId      = ''.obs;

  StreamSubscription<List<QuoteModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    isLoading.value = true;
    error.value     = '';

    _sub = _repo.watchQuotes(job.id).listen(
          (rawQuotes) async {
        final hydrated = await Future.wait(rawQuotes.map(_hydrateFixxer));
        quotes.assignAll(hydrated);
        isLoading.value = false;
      },
      onError: (e) {
        error.value     = e.toString();
        isLoading.value = false;
      },
    );
  }

  Future<QuoteModel> _hydrateFixxer(QuoteModel q) async {
    if (q.fixxerName.isNotEmpty) return q;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('fixxers')
          .doc(q.fixxerId)
          .get();
      if (doc.exists) {
        final d = doc.data()!;
        q.fixxerName     = d['fullName']        as String? ?? 'Service Provider';
        q.fixxerAvatar   = d['profileImageUrl'] as String? ?? '';
        q.fixxerFcmToken = d['fcmToken']        as String? ?? '';
      }
    } catch (_) {}
    return q;
  }

  Future<void> acceptQuote(QuoteModel quote) async {
    if (acceptingId.value.isNotEmpty) return;
    acceptingId.value = quote.fixxerId;
    try {
      await _repo.acceptQuote(job.id, quote.fixxerId);
      Get.snackbar(
        'Booked!',
        '${quote.fixxerName.isNotEmpty ? quote.fixxerName : "Service provider"} has been booked.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not accept quote: $e');
    } finally {
      acceptingId.value = '';
    }
  }

  Future<void> rejectQuote(QuoteModel quote) async {
    try {
      await _repo.rejectQuote(job.id, quote.fixxerId);
    } catch (e) {
      Get.snackbar('Error', 'Could not reject quote: $e');
    }
  }

  Future<void> refresh() async {
    await _sub?.cancel();
    _startListening();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  int get pendingCount =>
      quotes.where((q) => q.status == QuoteStatus.pending).length;

  bool get hasAccepted =>
      quotes.any((q) => q.status == QuoteStatus.accepted);
}