import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/domain/models/fixer_model.dart';
import 'package:servicex_client_app/presentation/screens/service_provider_profile/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

// ── Controller ────────────────────────────────────────────────────
class _ProviderListController extends GetxController {
  final String subcategoryId;
  _ProviderListController({required this.subcategoryId});

  final RxList<FixerModel> fixxers = <FixerModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = FirebaseFirestore.instance
        .collection('fixxers')
        .where('subCategories', arrayContains: subcategoryId)
        .snapshots()
        .listen(
          (snap) {
        fixxers.assignAll(
          snap.docs.map((d) => FixerModel.fromDoc(d)).toList(),
        );
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

// ── Screen ────────────────────────────────────────────────────────
class CatagoryServiceProviderScreen extends StatelessWidget {
  final String screenTitle;
  final String subcategoryId;

  const CatagoryServiceProviderScreen({
    super.key,
    required this.screenTitle,
    required this.subcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      _ProviderListController(subcategoryId: subcategoryId),
      tag: subcategoryId,
    );

    return Scaffold(
      appBar: XAppBar(title: screenTitle),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const SearchWithFilter(horPadding: 16),
            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Text(controller.error.value,
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                if (controller.fixxers.isEmpty) {
                  return const Center(
                    child: Text('No service providers found.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: controller.fixxers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _FixerCard(fixer: controller.fixxers[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fixer card ────────────────────────────────────────────────────
class _FixerCard extends StatelessWidget {
  final FixerModel fixer;
  const _FixerCard({required this.fixer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
            () => ServiceProviderProfileScreen(),
        arguments: fixer,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: XColors.lightTint.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: fixer.profileImageUrl.isNotEmpty
                  ? Image.network(
                fixer.profileImageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatar(),
              )
                  : _avatar(),
            ),
            const SizedBox(width: 12),

            // ── Info ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fixer.fullName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Iconsax.location,
                          size: 11, color: XColors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          fixer.address.isNotEmpty
                              ? fixer.address
                              : 'Location not set',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: XColors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Colors.amber),
                      const SizedBox(width: 2),
                      const Text(
                        '4.5', // extend with real rating field when available
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${fixer.hourlyRate.toStringAsFixed(0)}/hr',
                        style: const TextStyle(
                          fontSize: 11,
                          color: XColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Invite button ─────────────────────────────────────
            OutlinedButton(
              onPressed: () => Get.to(
                    () => ServiceProviderProfileScreen(),
                arguments: fixer,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                side: const BorderSide(color: XColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View',
                style: TextStyle(
                    fontSize: 11,
                    color: XColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() => Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: XColors.grey.withValues(alpha: 0.2),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.person, color: Colors.grey, size: 32),
  );
}