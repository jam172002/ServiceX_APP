import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import 'x_search_controller.dart';

/// Call via: SearchFilterSheet.show(context)
class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterSheet(),
    );
  }

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late SearchFilters _draft;
  late XSearchController _ctrl;

  // Local editable state
  RangeValues _rateRange = const RangeValues(0, 500);
  double _minRating = 0;
  String? _gender;
  String? _categoryId;
  List<String> _days = [];

  static const _allDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _dayShort = {
    'Monday': 'Mon', 'Tuesday': 'Tue', 'Wednesday': 'Wed',
    'Thursday': 'Thu', 'Friday': 'Fri', 'Saturday': 'Sat', 'Sunday': 'Sun',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<XSearchController>();
    _draft = _ctrl.activeFilters.value;
    _rateRange = RangeValues(
      _draft.minRate ?? 0,
      _draft.maxRate ?? 500,
    );
    _minRating = _draft.minRating ?? 0;
    _gender = _draft.gender;
    _categoryId = _draft.categoryId;
    _days = List.from(_draft.availableDays);
  }

  void _apply() {
    _ctrl.applyFilters(SearchFilters(
      minRate: _rateRange.start > 0 ? _rateRange.start : null,
      maxRate: _rateRange.end < 500 ? _rateRange.end : null,
      minRating: _minRating > 0 ? _minRating : null,
      gender: _gender,
      categoryId: _categoryId,
      availableDays: _days,
    ));
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _rateRange = const RangeValues(0, 500);
      _minRating = 0;
      _gender = null;
      _categoryId = null;
      _days = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: XColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Fixxers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset',
                      style: TextStyle(color: XColors.primary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: XColors.borderColor),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [

                  // ── Hourly Rate ──────────────────────────────────────────
                  _SectionLabel(label: 'Hourly Rate (PKR)'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Chip(label: 'PKR ${_rateRange.start.toInt()}'),
                      _Chip(label: 'PKR ${_rateRange.end.toInt()}${_rateRange.end >= 500 ? '+' : ''}'),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: XColors.primary,
                      thumbColor: XColors.primary,
                      overlayColor: XColors.primary.withValues(alpha: 0.1),
                      inactiveTrackColor: XColors.borderColor,
                    ),
                    child: RangeSlider(
                      values: _rateRange,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      onChanged: (v) => setState(() => _rateRange = v),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Minimum Rating ───────────────────────────────────────
                  _SectionLabel(label: 'Minimum Rating'),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final star = (i + 1).toDouble();
                      return GestureDetector(
                        onTap: () => setState(
                              () => _minRating = _minRating == star ? 0 : star,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.star5,
                                color: _minRating >= star
                                    ? XColors.warning
                                    : XColors.borderColor,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // label
                  ),
                  if (_minRating > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${_minRating.toInt()}+ stars',
                        style: TextStyle(
                          color: XColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ── Gender ───────────────────────────────────────────────
                  _SectionLabel(label: 'Gender'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Male', 'Female'].map((g) {
                      final selected = _gender == g;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _SelectChip(
                          label: g,
                          selected: selected,
                          onTap: () => setState(
                                () => _gender = selected ? null : g,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Category ─────────────────────────────────────────────
                  _SectionLabel(label: 'Category'),
                  const SizedBox(height: 8),
                  Obx(() {
                    final cats = _ctrl.allCategories;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cats.map((cat) {
                        final selected = _categoryId == cat.id;
                        return _SelectChip(
                          label: cat.name,
                          selected: selected,
                          onTap: () => setState(
                                () => _categoryId = selected ? null : cat.id,
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Available Days ───────────────────────────────────────
                  _SectionLabel(label: 'Available Days'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allDays.map((d) {
                      final selected = _days.contains(d);
                      return _SelectChip(
                        label: _dayShort[d]!,
                        selected: selected,
                        onTap: () => setState(() {
                          selected ? _days.remove(d) : _days.add(d);
                        }),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Apply button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: XColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: XColors.lightTint.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: XColors.primary,
      ),
    ),
  );
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? XColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? XColors.primary : XColors.borderColor,
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    ),
  );
}