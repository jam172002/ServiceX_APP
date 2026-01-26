import 'dart:async';
import 'package:get/get.dart';
import '../data/repos/wallet_repository.dart';
import '../domain/enums/app_enums.dart';
import '../domain/models/payment_card_model.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/wallet_model.dart';

class WalletController extends GetxController {
  final WalletRepository _repo;
  WalletController({required WalletRepository repo}) : _repo = repo;

  final Rxn<WalletModel> wallet = Rxn<WalletModel>();
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<PaymentCardModel> cards = <PaymentCardModel>[].obs;

  StreamSubscription<WalletModel?>? _walletSub;
  StreamSubscription<List<TransactionModel>>? _txSub;
  StreamSubscription<List<PaymentCardModel>>? _cardsSub;

  Future<void> bindWallet(String userId) async {
    await _repo.ensureWalletExists(userId);

    _walletSub?.cancel();
    _walletSub = _repo.watchWallet(userId).listen((w) => wallet.value = w);

    _txSub?.cancel();
    _txSub = _repo.watchTransactions(userId).listen(transactions.assignAll);

    _cardsSub?.cancel();
    _cardsSub = _repo.watchCards(userId).listen(cards.assignAll);
  }

  Future<void> toggleHidden(String userId, bool hidden) => _repo.setWalletHidden(userId, hidden);

  Future<String> addCard({
    required String userId,
    required String brand,
    required String last4,
    required bool makeDefault,
  }) =>
      _repo.addPaymentCard(userId: userId, brand: brand, last4: last4, makeDefault: makeDefault);

  Future<void> setDefaultCard(String userId, String cardId) => _repo.setDefaultCard(userId, cardId);

  Future<void> deleteCard(String cardId) => _repo.deleteCard(cardId);

  Future<String> addTransaction({
    required String walletId,
    required double amount,
    required TransactionType type,
    required TransactionStatus status,
    required String reference,
  }) =>
      _repo.addTransaction(
        walletId: walletId,
        amount: amount,
        type: type,
        status: status,
        reference: reference,
        createdAt: DateTime.now(),
      );

  @override
  void onClose() {
    _walletSub?.cancel();
    _txSub?.cancel();
    _cardsSub?.cancel();
    super.onClose();
  }
}
