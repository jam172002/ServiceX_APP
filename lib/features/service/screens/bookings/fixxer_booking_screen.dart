import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_booking_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerBookingScreen extends StatefulWidget {
  const FixxerBookingScreen({super.key});

  @override
  State<FixxerBookingScreen> createState() => _FixxerBookingScreenState();
}

class _FixxerBookingScreenState extends State<FixxerBookingScreen> {
  DateTime selectedDate = DateTime.now();

  // Dummy bookings
  List<FixxerBookingModel> allBookings = [
    FixxerBookingModel(
      providerName: "Ali Raza",
      serviceTitle: "Electrician",
      description: "Fix lights in kitchen",
      images: [
        "assets/images/service-provider.jpg",
        "assets/images/service-provider.jpg",
      ],
      dateTime: DateTime(2026, 1, 23, 11, 0),
      location: "Model Town, Bahawalpur",
      amount: 120,
    ),
    FixxerBookingModel(
      providerName: "Bilal Ahmed",
      serviceTitle: "Painter",
      description: "Paint living room",
      images: ["assets/images/service-provider.jpg"],
      dateTime: DateTime(2026, 1, 23, 13, 30),
      location: "Satellite Town",
      amount: 100,
    ),
    FixxerBookingModel(
      providerName: "Waqas",
      serviceTitle: "Plumber",
      description: "Fix leakage in bathroom",
      images: ["assets/images/service-provider.jpg"],
      dateTime: DateTime(2026, 1, 23, 9, 0),
      location: "Civic Center",
      amount: 150,
    ),
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

  List<FixxerBookingModel> bookingsForDate(DateTime date) {
    final filtered = allBookings.where((b) {
      return b.dateTime.year == date.year &&
          b.dateTime.month == date.month &&
          b.dateTime.day == date.day;
    }).toList();

    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  Color statusColor(String status) {
    switch (status) {
      case "Upcoming":
        return Colors.blue;
      case "Ongoing":
        return Colors.orange;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<String> statusesForDate(DateTime date) {
    return allBookings
        .where(
          (b) =>
              b.dateTime.year == date.year &&
              b.dateTime.month == date.month &&
              b.dateTime.day == date.day,
        )
        .map(
          (b) => b.isCancelled
              ? "Cancelled"
              : b.dateTime.isAfter(DateTime.now())
              ? "Upcoming"
              : b.dateTime.day == DateTime.now().day
              ? "Ongoing"
              : "Completed",
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = bookingsForDate(selectedDate);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Month/Year Selector
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(3000),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: XColors.primary,
                        onPrimary: Colors.white,
                        onSurface: XColors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: XColors.primary,
                        ),
                      ),
                      dialogTheme: DialogThemeData(
                        backgroundColor: XColors.lighterTint,
                      ),
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
                  setState(() => selectedDate = picked);
                }
              }
            },
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

          // Horizontal date selector
          SizedBox(
            height: 90,
            child: PageView.builder(
              controller: _pageController,
              itemCount: allDates.length,
              onPageChanged: (index) {
                setState(() => selectedDate = allDates[index]);
              },
              itemBuilder: (context, index) {
                final date = allDates[index];
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final statuses = statusesForDate(date);

                return Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() => selectedDate = date);
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
                          // Status dots
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
                                          : statusColor(s),
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

          // Bookings list
          Expanded(
            child: bookings.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/no-bookings.png",
                        width: width * 0.75,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No Bookings Found",
                        style: TextStyle(fontSize: 13, color: XColors.grey),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FixxerBookingCard(
                              booking: booking,
                              onTap: () {
                                Get.to(() => const FixxerJobDetailScreen());
                              },
                              onFavouriteToggle: () {
                                setState(() {
                                  booking.isFavourite = !booking.isFavourite;
                                });
                              },
                              alwaysFavourite: false,
                            ),
                          ),
                          if (index == bookings.length - 1)
                            const SizedBox(
                              height: kBottomNavigationBarHeight + 20,
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
