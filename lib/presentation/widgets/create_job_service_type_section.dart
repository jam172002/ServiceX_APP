import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ServiceTypeSection extends StatelessWidget {
  final List<Map<String, String>> allServices;
  final int? selectedIndex;
  final Function(Map<String, String> service, int? index) onServiceTap;

  const ServiceTypeSection({
    super.key,
    required this.allServices,
    required this.selectedIndex,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = List<Map<String, String>>.from(allServices.take(7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Service Type",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: display.length + 1, // +1 for "Other" button
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            if (i == display.length) {
              // "Other" button
              return GestureDetector(
                onTap: () => onServiceTap({'title': 'Other'}, null),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/other.png',
                        height: 22,
                        color: XColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Other',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }

            final svc = display[i];
            final isSelected = selectedIndex == i;

            return GestureDetector(
              onTap: () => onServiceTap(svc, i),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? XColors.primary
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      svc['img']!,
                      height: 22,
                      color: isSelected ? Colors.white : XColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    svc['title']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
