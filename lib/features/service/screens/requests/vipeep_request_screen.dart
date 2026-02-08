import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/screens/requests/request_detail_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/request_screen_card.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/request_status_filter.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class VipeepRequestScreen extends StatefulWidget {
  const VipeepRequestScreen({super.key});

  @override
  State<VipeepRequestScreen> createState() => _VipeepRequestScreenState();
}

class _VipeepRequestScreenState extends State<VipeepRequestScreen> {
  String selectedStatus = 'All';

  // Demo data for testing
  final List<Map<String, dynamic>> demoRequests = List.generate(10, (index) {
    return {
      'category': 'Electrical',
      'title': 'Wiring & Rewiring #$index',
      'description':
          'Quick rewiring work for home electrical setup, includes 3 rooms and the outdoor area.',
      'location': 'Model Town, Bahawalpur',
      'status': index % 2 == 0 ? 'New' : 'Completed',
      'jobType': index % 3 == 0 ? 'Open For All' : 'Private',
      'budget': '\$${10 + index} - \$${100 + index}',
      'date': '25 Dec 2025',
      'time': '11:00 AM',
      'additionalImages': index % 4,
      'imageAsset': XImages.serviceProvider,
    };
  });

  @override
  Widget build(BuildContext context) {
    // Filter data based on selected status
    final filteredRequests = selectedStatus == 'All'
        ? demoRequests
        : demoRequests
              .where(
                (req) =>
                    req['status'].toString().toLowerCase() ==
                    selectedStatus.toLowerCase(),
              )
              .toList();

    return Scaffold(
      appBar: XAppBar(title: 'Job Requests', showBackIcon: false),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            RequestStatusFilter(
              selectedStatus: selectedStatus,
              onStatusSelected: (status) {
                setState(() {
                  selectedStatus = status;
                });
              },
            ),
            const SizedBox(height: 12),

            // Expanded content
            Expanded(
              child: filteredRequests.isEmpty
                  ? SizedBox(
                      width: double.infinity,
                      child: Align(
                        alignment: const Alignment(0, -0.5), // Slight
                        child: Image.asset(
                          'assets/images/No-data.png',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: filteredRequests.length + 1,
                      itemBuilder: (context, index) {
                        if (index < filteredRequests.length) {
                          final req = filteredRequests[index];
                          return RequestScreenCard(
                            category: req['category'],
                            title: req['title'],
                            description: req['description'],
                            location: req['location'],
                            status: req['status'],
                            jobType: req['jobType'],
                            budget: req['budget'],
                            date: req['date'],
                            time: req['time'],
                            additionalImages: req['additionalImages'],
                            imageAsset: req['imageAsset'],
                            onTap: () {
                              Get.to(
                                () => RequestDetailScreen(
                                  isRequestDetailScreen: true,
                                ),
                              );
                            },
                          );
                        } else {
                          return const SizedBox(height: 80);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
