import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../enums/app_enums.dart';
import '../models/payment_card_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final FirebaseFirestore _db;
  WalletRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _walletDoc(String userId) =>
      _db.collection(FirestorePaths.wallets).doc(userId);

  CollectionReference<Map<String, dynamic>> get _txCol =>
      _db.collection(FirestorePaths.transactions);

  CollectionReference<Map<String, dynamic>> get _cardCol =>
      _db.collection(FirestorePaths.paymentCards);

  Future<void> ensureWalletExists(String userId) async {
    final ref = _walletDoc(userId);
    final snap = await ref.get();
    if (snap.exists) return;
    final wallet = WalletModel(userId: userId, balance: 0, isHidden: false);
    await ref.set(wallet.toJson(), SetOptions(merge: false));
  }

  Stream<WalletModel?> watchWallet(String userId) {
    return _walletDoc(userId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? <String, dynamic>{};
      data['userId'] = snap.id;
      return WalletModel.fromJson(data);
    });
  }

  Future<void> setWalletHidden(String userId, bool hidden) async {
    await _walletDoc(userId).set({'isHidden': hidden}, SetOptions(merge: true));
  }

  Future<String> addTransaction({
    required String walletId,
    required double amount,
    required TransactionType type,
    required TransactionStatus status,
    required String reference,
    required DateTime createdAt,
  }) async {
    final ref = _txCol.doc();
    final tx = TransactionModel(
      id: ref.id,
      walletId: walletId,
      amount: amount,
      type: type,
      status: status,
      createdAt: createdAt,
      reference: reference,
    );
    await ref.set(tx.toJson(), SetOptions(merge: true));

    final walletRef = _walletDoc(walletId);
    await _db.runTransaction((t) async {
      final snap = await t.get(walletRef);
      final data = snap.data() ?? <String, dynamic>{};
      final current = (data['balance'] is num)
          ? (data['balance'] as num).toDouble()
          : 0.0;
      final next = type == TransactionType.credit
          ? current + amount
          : current - amount;
      t.set(walletRef, {'balance': next}, SetOptions(merge: true));
    });

    return ref.id;
  }

  Stream<List<TransactionModel>> watchTransactions(
    String walletId, {
    int limit = 200,
  }) {
    return _txCol
        .where('walletId', isEqualTo: walletId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) {
          return q.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return TransactionModel.fromJson(data);
          }).toList();
        });
  }

  Future<String> addPaymentCard({
    required String userId,
    required String brand,
    required String last4,
    required bool makeDefault,
  }) async {
    final ref = _cardCol.doc();
    final card = PaymentCardModel(
      id: ref.id,
      userId: userId,
      brand: brand,
      last4: last4,
      isDefault: makeDefault,
    );

    await _db.runTransaction((t) async {
      if (makeDefault) {
        final existing = await _cardCol
            .where('userId', isEqualTo: userId)
            .get();
        for (final d in existing.docs) {
          t.set(d.reference, {'isDefault': false}, SetOptions(merge: true));
        }
      }
      t.set(ref, card.toJson(), SetOptions(merge: true));
    });

    return ref.id;
  }

  Stream<List<PaymentCardModel>> watchCards(String userId) {
    return _cardCol.where('userId', isEqualTo: userId).snapshots().map((q) {
      return q.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return PaymentCardModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> setDefaultCard(String userId, String cardId) async {
    await _db.runTransaction((t) async {
      final all = await _cardCol.where('userId', isEqualTo: userId).get();
      for (final d in all.docs) {
        t.set(d.reference, {
          'isDefault': d.id == cardId,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> deleteCard(String cardId) async {
    await _cardCol.doc(cardId).delete();
  }
}
