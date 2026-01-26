import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/authentication/screens/signup/fixxers_profile_data_gathering_screen.dart';
import 'package:servicex_client_app/features/authentication/screens/verification/fixxer_professional_verification.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerVerificationStatusScreen extends StatelessWidget {
  /// status: pending | verified | rejected
  final String status;

  /// Only used when status == rejected
  final String? rejectionReason;

  const FixxerVerificationStatusScreen({
    super.key,
    this.status = 'verified',
    this.rejectionReason,
  });

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Verification Status', showBackIcon: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _statusCard(),
            const SizedBox(height: 24),

            if (isVerified) _setupProfileButton(),
            if (isRejected) _resubmitButton(),
          ],
        ),
      ),
    );
  }

  // ---------- Status Card ----------
  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: XColors.secondaryBG,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor().withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(), size: 22, color: _statusColor()),
              const SizedBox(width: 8),
              Text(
                _statusTitle(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _statusDescription(),
            style: const TextStyle(
              fontSize: 12,
              color: XColors.grey,
              height: 1.4,
            ),
          ),

          if (isRejected && rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: XColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, size: 16, color: XColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rejectionReason!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: XColors.danger,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- Buttons ----------
  Widget _setupProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(LucideIcons.user_cog, size: 18),
        label: const Text(
          'Setup Professional Profile',
          style: TextStyle(fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Get.to(() => FixxersProfileDataGatheringScreen());
        },
      ),
    );
  }

  Widget _resubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(
          LucideIcons.refresh_ccw,
          size: 18,
          color: XColors.black,
        ),
        label: const Text(
          'Resubmit Verification',
          style: TextStyle(fontSize: 13, color: XColors.black),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: XColors.danger.withValues(alpha: 0.6)),
        ),
        onPressed: () {
          Get.offAll(() => FixxerProfessionalVerification());
        },
      ),
    );
  }

  // ---------- Helpers ----------
  IconData _statusIcon() {
    if (isVerified) return LucideIcons.badge_check;
    if (isRejected) return LucideIcons.circle_x;
    return LucideIcons.clock;
  }

  Color _statusColor() {
    if (isVerified) return XColors.success;
    if (isRejected) return XColors.danger;
    return XColors.primary;
  }

  String _statusTitle() {
    if (isVerified) return 'Verified';
    if (isRejected) return 'Verification Rejected';
    return 'Verification Pending';
  }

  String _statusDescription() {
    if (isVerified) {
      return 'Your professional profile has been successfully verified.';
    }
    if (isRejected) {
      return 'Your verification request was rejected. Please review the reason below and resubmit.';
    }
    return 'Your documents are under review. This usually takes 24–48 hours.';
  }
}
