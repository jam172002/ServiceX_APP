import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/controllers/wallet_controller.dart';

class WalletCard extends StatelessWidget {
  WalletCard({super.key});

  final WalletController controller = Get.put(WalletController());

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
          //? Left: Balance
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
                  //?  Count Up / Down Animation
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
                          return const _BlurBalance();
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

                  //? Eye Icon
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

          /// 🔹 Right: Wallet Icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.walletIcon,
              color: controller.iconColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Blur Balance (Light Mode)
class _BlurBalance extends StatelessWidget {
  const _BlurBalance();

  @override
  Widget build(BuildContext context) {
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
}
