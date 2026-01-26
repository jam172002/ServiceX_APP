import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class AllServicesDialog extends StatelessWidget {
  final List<Map<String, String>> allServices;
  final int? selectedServiceIndex;
  final Function(int) onServiceSelected;

  const AllServicesDialog({
    super.key,
    required this.allServices,
    required this.selectedServiceIndex,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: XColors.secondaryBG,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select a Service",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300, // adjust as needed
              child: GridView.builder(
                itemCount: allServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final svc = allServices[index];
                  final isSelected =
                      selectedServiceIndex != null &&
                      allServices[selectedServiceIndex!]['title'] ==
                          svc['title'];

                  return GestureDetector(
                    onTap: () {
                      onServiceSelected(index);
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          textAlign: TextAlign.center,
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
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
