import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// 🔹 Wallet Controller
class WalletController extends GetxController {
  final RxBool hideBalance = false.obs;
  final RxDouble balance = 2500.0.obs;

  void toggleVisibility() {
    HapticFeedback.lightImpact();
    hideBalance.toggle();
  }

  /// 🔹 Fixed Light Gradient
  LinearGradient get gradient => LinearGradient(
    colors: [
      XColors.lightTint.withValues(alpha: 0.1),
      XColors.lightTint.withValues(alpha: 0.5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 🔹 Fixed Wallet Icon
  IconData get walletIcon => Iconsax.wallet;
  Color get iconColor => XColors.primary;
}
