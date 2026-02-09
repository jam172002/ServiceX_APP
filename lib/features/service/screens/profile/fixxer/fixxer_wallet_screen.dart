import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// ------------------- Controller -------------------
class FixxerWalletController extends GetxController {
  final RxBool hideBalance = false.obs;
  final RxDouble balance = 0.0.obs;

  /// Transaction list: "pending", "cleared", "transferred", "deducted"
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Add dummy transactions
    transactions.addAll([
      {
        'title': 'AC Repair Service',
        'subTitle': '24 Dec, 2025 · 01:00 AM',
        'amount': 350.0,
        'status': 'pending',
        'avatar': 'assets/icons/ac.png',
      },
      {
        'title': 'Package Purchased',
        'subTitle': '23 Dec, 2025 · 02:00 PM',
        'amount': 120.0,
        'status': 'deducted',
        'avatar': 'assets/icons/crown.png',
      },
      {
        'title': 'Electric Repair',
        'subTitle': '22 Dec, 2025 · 10:00 AM',
        'amount': 500.0,
        'status': 'cleared',
        'avatar': 'assets/icons/flash.png',
      },
      {
        'title': 'Plumbing Job',
        'subTitle': '21 Dec, 2025 · 03:30 PM',
        'amount': 200.0,
        'status': 'cleared',
        'avatar': 'assets/icons/plumber.png',
      },
      {
        'title': 'Painting Package',
        'subTitle': '20 Dec, 2025 · 12:00 PM',
        'amount': 150.0,
        'status': 'transferred',
        'avatar': 'assets/icons/paint.png',
      },
    ]);

    _calculateBalance();
  }

  void _calculateBalance() {
    double total = 0;
    for (var tx in transactions) {
      if (tx['status'] == 'cleared') total += tx['amount'];
      if (tx['status'] == 'deducted') total -= tx['amount'];
    }
    if (total < 0) total = 0;
    balance.value = total;
  }

  void toggleVisibility() {
    HapticFeedback.lightImpact();
    hideBalance.toggle();
  }

  LinearGradient get gradient => LinearGradient(
    colors: [
      XColors.lightTint.withValues(alpha: 0.1),
      XColors.lightTint.withValues(alpha: 0.5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  IconData get walletIcon => Iconsax.wallet;
  Color get iconColor => XColors.primary;

  /// Transfer cleared money to card
  void transferToCard(int index) {
    var tx = transactions[index];
    if (tx['status'] == 'cleared') {
      tx['status'] = 'transferred';
      transactions[index] = tx;
      _calculateBalance();
    }
  }

  /// Add money to wallet
  void addMoney(double amount) {
    balance.value += amount;
    transactions.insert(0, {
      'title': 'Wallet Top-Up',
      'subTitle': 'Now',
      'amount': amount,
      'status': 'cleared',
      'avatar': 'assets/icons/dollar.png',
    });
  }
}

/// ------------------- Wallet Card -------------------
class FixxerWalletCard extends StatelessWidget {
  FixxerWalletCard({super.key});
  final FixxerWalletController controller = Get.put(FixxerWalletController());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: controller.gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Balance Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Obx(
                    () => TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: controller.hideBalance.value
                            ? controller.balance.value
                            : 0,
                        end: controller.hideBalance.value
                            ? 0
                            : controller.balance.value,
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        if (controller.hideBalance.value && value == 0) {
                          return const Text(
                            '****',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Colors.black54,
                            ),
                          );
                        }
                        return Text(
                          '\$${value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: controller.toggleVisibility,
                    child: Obx(
                      () => Icon(
                        controller.hideBalance.value
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Right: Wallet Icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                controller.walletIcon,
                color: controller.iconColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------- Transaction Tile -------------------
class FixxerTransactionTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final double amount;
  final String status; // "pending", "cleared", "transferred", "deducted"
  final String avatarAsset;
  final VoidCallback? onTransfer;

  const FixxerTransactionTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.amount,
    required this.status,
    required this.avatarAsset,
    this.onTransfer,
  });

  Color get amountColor {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "cleared":
        return Colors.green;
      case "transferred":
        return Colors.blue;
      case "deducted":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String get statusText {
    switch (status) {
      case "pending":
        return "Pending";
      case "cleared":
        return "Cleared";
      case "transferred":
        return "Transferred";
      case "deducted":
        return "Deducted";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(avatarAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (status == "deducted" ? "-\$$amount" : "+\$$amount"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (status == 'cleared')
                ElevatedButton(
                  onPressed: onTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Transfer to Card',
                    style: TextStyle(fontSize: 10),
                  ),
                )
              else
                Text(
                  statusText,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------- Wallet Screen -------------------
class FixxerWalletScreen extends StatelessWidget {
  FixxerWalletScreen({super.key});
  final FixxerWalletController controller = Get.put(FixxerWalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(
        title: 'Wallet',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.circle_plus, color: Colors.black),
            onPressed: () {
              // Example: add $100 to wallet
              controller.addMoney(100);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              FixxerWalletCard(),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tx = controller.transactions[index];
                  return FixxerTransactionTile(
                    title: tx['title'],
                    subTitle: tx['subTitle'],
                    amount: tx['amount'],
                    status: tx['status'],
                    avatarAsset: tx['avatar'],
                    onTransfer: tx['status'] == 'cleared'
                        ? () => controller.transferToCard(index)
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
