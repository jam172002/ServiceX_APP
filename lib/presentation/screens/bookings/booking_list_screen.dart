import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/domain/repos/booking_repository.dart';
import 'package:servicex_client_app/presentation/screens/bookings/controller/booking_list_controller.dart';
import 'package:servicex_client_app/presentation/widgets/booking_screen_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late final BookingListController _c;
  DateTime selectedDate = DateTime.now();

  // ── Status sort order (matches original) ──────────────────────
  final List<String> _statusOrder = [
    'booked',
    'rebooked',
    'pending',
    'inProgress', // BookingStatus.inProgress.name
    'completed',
    'cancelled',
  ];

  late final PageController _pageController;
  late final List<DateTime> allDates;

  @override
  void initState() {
    super.initState();

    // ── Controller ────────────────────────────────────────────────
    _c = Get.put(BookingListController(repo: BookingRepository()));

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) _c.bindUserBookings(uid);

    // ── Date strip ────────────────────────────────────────────────
    allDates = List.generate(
      DateTime(3000).difference(DateTime(2000)).inDays + 1,
          (i) => DateTime(2000).add(Duration(days: i)),
    );

    final todayIndex = allDates.indexWhere(
          (d) =>
      d.year == DateTime.now().year &&
          d.month == DateTime.now().month &&
          d.day == DateTime.now().day,
    );

    _pageController = PageController(
      initialPage: todayIndex,
      viewportFraction: 1 / 5,
    );
  }

  @override
  void dispose() {
    Get.delete<BookingListController>();
    _pageController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────

  /// Convert BookingModel → the Map shape BookingScreenCard already expects,
  /// so the card widget stays untouched.
  Map<String, dynamic> _toCardData(BookingModel b) => {
    'date': b.scheduledAt,
    'spName': b.fixerId, // swap for fixer display name if you cache it
    'spType': b.categoryName,
    'status': b.status.name,
    'time': TimeOfDay.fromDateTime(b.scheduledAt).format(context),
    'price': b.budgetMax.toString(),
    'desc': b.details,
    'distance': '', // enrich later from geo if needed
    'location': b.address,
  };

  List<BookingModel> _bookingsForDate(
      List<BookingModel> all,
      DateTime date,
      ) =>
      all.where((b) {
        final d = b.scheduledAt;
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).toList()
        ..sort((a, b) => _statusOrder
            .indexOf(a.status.name)
            .compareTo(_statusOrder.indexOf(b.status.name)));

  List<BookingModel> _bookingsWithDate(
      List<BookingModel> all,
      DateTime date,
      ) =>
      all.where((b) {
        final d = b.scheduledAt;
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).toList();

  Color _statusColor(String status) {
    switch (status) {
      case 'booked':
      case 'rebooked':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inProgress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: XColors.primary,
            onPrimary: Colors.white,
            onSurface: XColors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: XColors.primary),
          ),
          dialogTheme:
          const DialogThemeData(backgroundColor: XColors.lighterTint),
        ),
        child: child!,
      ),
    );
    if (picked == null || picked == selectedDate) return;

    final index = allDates.indexWhere(
          (d) =>
      d.year == picked.year &&
          d.month == picked.month &&
          d.day == picked.day,
    );
    if (index != -1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => selectedDate = picked);
    }
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = XHelperFunctions.screenWidth();

    return Scaffold(
      body: Obx(() {
        final allBookings = _c.userBookings.toList();
        final bookingsForDate = _bookingsForDate(allBookings, selectedDate);

        return Column(
          children: [
            const SizedBox(height: 12),

            // ── Month / Year picker ─────────────────────────────
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: XColors.lighterTint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: XColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Horizontal date strip ───────────────────────────
            SizedBox(
              height: 80,
              child: PageView.builder(
                controller: _pageController,
                itemCount: allDates.length,
                onPageChanged: (index) =>
                    setState(() => selectedDate = allDates[index]),
                itemBuilder: (_, index) {
                  final date = allDates[index];
                  final isSelected = date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  // Dot indicators from live data
                  final statuses = _bookingsWithDate(allBookings, date)
                      .map((b) => b.status.name)
                      .toList();

                  return Center(
                    child: GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? XColors.primary
                              : XColors.lighterTint.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? XColors.primary
                                : XColors.borderColor,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                isSelected ? Colors.white : XColors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : XColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: statuses
                                  .map(
                                    (s) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : _statusColor(s),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Booking list / empty state ──────────────────────
            Expanded(
              child: bookingsForDate.isEmpty
                  ? _buildEmptyState(width)
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: bookingsForDate.length + 1,
                itemBuilder: (_, index) {
                  if (index == bookingsForDate.length) {
                    return const SizedBox(
                      height: kBottomNavigationBarHeight + 40,
                    );
                  }
                  return BookingScreenCard(
                    data: _toCardData(bookingsForDate[index]),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Image.asset('assets/images/no-bookings.png', width: width * 0.75),
          const SizedBox(height: 12),
          const Text(
            'No Bookings Found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: XColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}