import 'package:flutter/material.dart';
import 'package:servicex_client_app/presentation/widgets/booking_screen_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';
import 'package:intl/intl.dart';

class VipeepBookingScreen extends StatefulWidget {
  const VipeepBookingScreen({super.key});

  @override
  State<VipeepBookingScreen> createState() => _VipeepBookingScreenState();
}

class _VipeepBookingScreenState extends State<VipeepBookingScreen> {
  DateTime selectedDate = DateTime.now();

  // Dummy bookings
  final List<Map<String, dynamic>> allBookings = [
    {
      "date": DateTime(2026, 1, 3),
      "spName": "Ali Raza",
      "spType": "Electrician",
      "status": "booked",
      "time": "11:00 AM",
      "price": "120",
      "desc": "Short description here...",
      "distance": "2.5 km away",
      "location": "Model Town, Bahawalpur",
    },
    {
      "date": DateTime(2026, 1, 3),
      "spName": "Bilal Ahmed",
      "spType": "Painter",
      "status": "pending",
      "time": "01:30 PM",
      "price": "90",
      "desc": "Pending job…",
      "distance": "4 km away",
      "location": "Satellite Town",
    },
    {
      "date": DateTime(2026, 1, 3),
      "spName": "Waqas",
      "spType": "Plumber",
      "status": "completed",
      "time": "09:00 AM",
      "price": "150",
      "desc": "Completed description",
      "distance": "1.7 km away",
      "location": "Civic Center",
    },
  ];

  final List<String> statusOrder = [
    "booked",
    "rebooked",
    "pending",
    "inprogress",
    "completed",
    "cancelled",
  ];

  late final PageController _pageController;
  late final List<DateTime> allDates;

  @override
  void initState() {
    super.initState();

    allDates = List.generate(
      DateTime(3000).difference(DateTime(2000)).inDays + 1,
      (index) => DateTime(2000).add(Duration(days: index)),
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

    selectedDate = DateTime.now();
  }

  Color bookingStatusColor(String status) {
    switch (status) {
      case "booked":
      case "rebooked":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "inprogress":
        return Colors.purple;
      case "completed":
        return Colors.teal;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<String> bookingStatuses(DateTime date) {
    return allBookings
        .where(
          (b) =>
              b["date"].year == date.year &&
              b["date"].month == date.month &&
              b["date"].day == date.day,
        )
        .map((b) => b["status"] as String)
        .toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: XColors.primary, // header background
              onPrimary: Colors.white, // header text color
              onSurface: XColors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: XColors.primary, // button text color
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: XColors.lighterTint,
            ), // background
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
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
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = XHelperFunctions.screenWidth();

    List<Map<String, dynamic>> bookingsForDate = allBookings
        .where(
          (b) =>
              b["date"].year == selectedDate.year &&
              b["date"].month == selectedDate.month &&
              b["date"].day == selectedDate.day,
        )
        .toList();

    bookingsForDate.sort(
      (a, b) => statusOrder
          .indexOf(a["status"])
          .compareTo(statusOrder.indexOf(b["status"])),
    );

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Month/Year selector
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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

          // Horizontal Date Selector
          SizedBox(
            height: 80,
            child: PageView.builder(
              controller: _pageController,
              itemCount: allDates.length,
              onPageChanged: (index) {
                setState(() {
                  selectedDate = allDates[index];
                });
              },
              itemBuilder: (context, index) {
                final date = allDates[index];
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;

                final statuses = bookingStatuses(date);

                return Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
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
                          width: 1,
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
                              color: isSelected ? Colors.white : XColors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : XColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Booking indicators
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
                                          : bookingStatusColor(s),
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

          // Booking List or Empty State
          Expanded(
            child: bookingsForDate.isEmpty
                ? _buildEmptyState(width)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: bookingsForDate.length + 1,
                    itemBuilder: (context, index) {
                      if (index == bookingsForDate.length) {
                        return SizedBox(
                          height: kBottomNavigationBarHeight + 40,
                        );
                      }
                      return BookingScreenCard(data: bookingsForDate[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset("assets/images/no-bookings.png", width: width * 0.75),
          const SizedBox(height: 12),
          const Text(
            "No Bookings Found",
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
