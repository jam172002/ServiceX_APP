import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

void fixxerRequestFilterSheet({
  required BuildContext context,
  required RangeValues budgetRange,
  required ValueChanged<RangeValues> onBudgetChanged,
  required double maxDistance,
  required ValueChanged<double> onDistanceChanged,
  DateTimeRange? selectedDateRange,
  required ValueChanged<DateTimeRange?> onDateRangeChanged,
  required VoidCallback onClear,
  required VoidCallback onApply,
}) {
  RangeValues localBudgetRange = budgetRange;
  double localMaxDistance = maxDistance.clamp(1, 100);
  DateTimeRange? localDateRange = selectedDateRange;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                onClear();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: XColors.primary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// Budget
                        const Text('Budget Range'),
                        RangeSlider(
                          values: localBudgetRange,
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          activeColor: XColors.primary,
                          inactiveColor: XColors.borderColor,
                          labels: RangeLabels(
                            '\$${localBudgetRange.start.round()}',
                            '\$${localBudgetRange.end.round()}',
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              localBudgetRange = val;
                            });
                          },
                          onChangeEnd: (val) {
                            onBudgetChanged(val);
                          },
                        ),

                        const SizedBox(height: 16),

                        /// Distance (UI only, no filter)
                        const Text('Max Distance (km)'),
                        Slider(
                          value: localMaxDistance,
                          min: 1,
                          max: 100,
                          activeColor: XColors.primary,
                          inactiveColor: XColors.borderColor,
                          divisions: 100,
                          label: '${localMaxDistance.round()} km',
                          onChanged: (val) {
                            setModalState(() {
                              localMaxDistance = val;
                            });
                          },
                          onChangeEnd: (val) => onDistanceChanged(val),
                        ),

                        const SizedBox(height: 16),

                        /// Date
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Iconsax.calendar,
                            color: XColors.primary,
                          ),
                          title: Text(
                            localDateRange == null
                                ? 'Select Date Range'
                                : '${DateFormat('dd MMM').format(localDateRange!.start)} - '
                                      '${DateFormat('dd MMM yyyy').format(localDateRange!.end)}',
                            style: TextStyle(color: XColors.black),
                          ),
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              initialDateRange: localDateRange,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: XColors.primary,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: XColors.primary,
                                      ),
                                    ),
                                    dialogTheme: const DialogThemeData(
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setModalState(() {
                                localDateRange = picked;
                              });
                              onDateRangeChanged(picked);
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        /// Apply
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: XColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              onBudgetChanged(localBudgetRange);
                              onDistanceChanged(localMaxDistance);
                              onDateRangeChanged(localDateRange);
                              onApply();
                              Navigator.pop(context);
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}
