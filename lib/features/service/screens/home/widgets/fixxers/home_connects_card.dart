import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

class HomeConnectsCard extends StatelessWidget {
  final int remainingConnects;
  final String activePackage;
  final int todaysProjects;
  final List<DateTime> bookedDates;
  final VoidCallback? onAddConnectsTap;

  const HomeConnectsCard({
    super.key,
    required this.remainingConnects,
    required this.activePackage,
    required this.todaysProjects,
    required this.bookedDates,
    this.onAddConnectsTap,
  });

  //this is the test commit for github
  @override
  Widget build(BuildContext context) {
    // generate next 14 days
    List<DateTime> upcomingDates = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Connects Remaining + Add Button
          Row(
            children: [
              CircularPercentIndicator(
                radius: 30.0,
                lineWidth: 6.0,
                percent: (remainingConnects / 20).clamp(0.0, 1.0),
                center: Text(
                  "$remainingConnects",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.green.withValues(alpha: 0.2),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 16),
              // Connects info and active package
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Connects Remaining",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Active Package: $activePackage",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Add Connects button
              IconButton(
                onPressed: onAddConnectsTap ?? () {},
                icon: Icon(Iconsax.add_circle, color: Colors.green, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.grey.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 12),

          // Today's Projects
          Row(
            children: [
              const Text(
                "Today's Projects: ",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                "$todaysProjects",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Upcoming Booking Dates
          SizedBox(
            height: 65,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingDates.length,
              itemBuilder: (context, index) {
                DateTime date = upcomingDates[index];
                String day = [
                  "Sun",
                  "Mon",
                  "Tue",
                  "Wed",
                  "Thu",
                  "Fri",
                  "Sat",
                ][date.weekday % 7];
                String formattedDate = "${date.day}";

                bool isBooked = bookedDates.any(
                  (d) =>
                      d.year == date.year &&
                      d.month == date.month &&
                      d.day == date.day,
                );

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: isBooked ? XColors.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: isBooked
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            color: isBooked ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isBooked ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
