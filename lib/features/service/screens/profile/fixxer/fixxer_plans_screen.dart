import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// ------------------------------------------------------------
/// CONTROLLER
/// ------------------------------------------------------------
class ConnectPlansController extends GetxController {
  final selectedIndex = (-1).obs;
  final remainingConnects = 0.obs;

  void purchasePlan(int index, int connects) {
    selectedIndex.value = index;
    remainingConnects.value = connects;
  }

  bool isActive(int index) => selectedIndex.value == index;
}

/// ------------------------------------------------------------
/// SCREEN
/// ------------------------------------------------------------
class FixxerPlansScreen extends StatelessWidget {
  FixxerPlansScreen({super.key});

  final controller = Get.put(ConnectPlansController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Packages'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final plan = _plans[index];
          return Obx(
            () => ConnectPlanCard(
              index: index,
              title: plan.title,
              description: plan.description,
              price: plan.price,
              duration: plan.validity,
              features: plan.features,
              connects: plan.connects,
              isPopular: plan.isPopular,
              isActive: controller.isActive(index),
              remainingConnects: controller.remainingConnects.value,
              onPurchase: () {
                controller.purchasePlan(index, plan.connects);
              },
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PLAN CARD
/// ------------------------------------------------------------
class ConnectPlanCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final int price;
  final String duration;
  final int connects;
  final List<String> features;
  final bool isPopular;
  final bool isActive;
  final int remainingConnects;
  final VoidCallback onPurchase;

  const ConnectPlanCard({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.connects,
    required this.features,
    required this.isPopular,
    required this.isActive,
    required this.remainingConnects,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1 : 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: XColors.secondaryBG,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: Colors.green, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            /// POPULAR TAG
            if (isPopular)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

            /// TOP INFO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: XColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: XColors.black,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PKR $price',
                          style: const TextStyle(
                            color: XColors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/$duration',
                          style: const TextStyle(
                            color: XColors.grey,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// RIGHT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: features
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.circle,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      f,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: XColors.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ACTIVE INFO
            if (isActive) ...[
              Row(
                children: [
                  const Icon(LucideIcons.zap, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Remaining Connects: $remainingConnects',
                    style: const TextStyle(color: XColors.black, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            /// BUTTON
            GestureDetector(
              onTap: isActive ? null : onPurchase,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? XColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: XColors.primary, width: 1.2),
                ),
                child: Center(
                  child: Text(
                    isActive ? 'Active Plan' : 'Buy Connects',
                    style: TextStyle(
                      color: isActive ? Colors.white : XColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// DUMMY DATA MODEL
/// ------------------------------------------------------------
class ConnectPlan {
  final String title;
  final String description;
  final int price;
  final String validity;
  final int connects;
  final bool isPopular;
  final List<String> features;

  ConnectPlan({
    required this.title,
    required this.description,
    required this.price,
    required this.validity,
    required this.connects,
    required this.isPopular,
    required this.features,
  });
}

final _plans = [
  ConnectPlan(
    title: 'Starter Connects',
    description: 'For new providers applying to a few jobs.',
    price: 999,
    validity: '30 days',
    connects: 20,
    isPopular: false,
    features: ['20 Job Connects', '30 Days Validity', 'Basic Visibility'],
  ),
  ConnectPlan(
    title: 'Pro Connects',
    description: 'For active professionals applying daily.',
    price: 2499,
    validity: '60 days',
    connects: 60,
    isPopular: true,
    features: ['60 Job Connects', 'Priority Job Access', 'Higher Visibility'],
  ),
  ConnectPlan(
    title: 'Elite Connects',
    description: 'Maximum exposure for top providers.',
    price: 4999,
    validity: '90 days',
    connects: 150,
    isPopular: false,
    features: ['150 Job Connects', 'Top Provider Badge', 'Maximum Visibility'],
  ),
];
