import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/models/fixxer_job_request_model.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_booking_card.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/fixxers/fixxer_job_request_card.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

class FixxerFavouriteScreen extends StatefulWidget {
  const FixxerFavouriteScreen({super.key});

  @override
  State<FixxerFavouriteScreen> createState() => _FixxerFavouriteScreenState();
}

class _FixxerFavouriteScreenState extends State<FixxerFavouriteScreen> {
  /// Dummy job requests (all favourited)
  final List<FixxerJobRequestModel> _jobRequests = List.generate(
    3,
    (index) => FixxerJobRequestModel(
      clientName: 'Client ${index + 1}',
      serviceTitle: 'Service ${index + 1}',
      type: index % 2 == 0
          ? FixxerJobRequestType.direct
          : FixxerJobRequestType.open,
      description: 'This is a description for job request ${index + 1}.',
      minBudget: 100 + index * 10,
      maxBudget: 200 + index * 20,
      location: 'City ${index + 1}',
      dateTime: DateTime.now().subtract(Duration(days: index)),
      images: [
        'assets/images/service-provider.jpg',
        'assets/images/service-provider2.jpg',
      ],
    ),
  );

  /// Dummy bookings (all favourited)
  final List<FixxerBookingModel> _bookings = List.generate(
    2,
    (index) => FixxerBookingModel(
      providerName: 'Provider ${index + 1}',
      serviceTitle: 'Service ${index + 1}',
      description: 'This is a description for booking ${index + 1}.',
      amount: 150 + index * 50,
      dateTime: DateTime.now().add(Duration(days: index)),
      location: 'City ${index + 1}',
      images: [
        'assets/images/service-provider.jpg',
        'assets/images/service-provider2.jpg',
      ],
      isFavourite: true, // Favourited by default
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Combine all favourites
    final allFavourites = [..._jobRequests, ..._bookings];

    return Scaffold(
      appBar: XAppBar(title: 'Favourites'),
      body: allFavourites.isEmpty
          ? const Center(
              child: Text(
                'No favourites yet',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: allFavourites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = allFavourites[index];

                /// ---------------- Job Request Card ----------------
                if (item is FixxerJobRequestModel) {
                  return FixxerJobRequestCard(
                    job: item,
                    onTap: () {
                      Get.to(() => FixxerJobDetailScreen());
                    },
                    onRemove: () {
                      setState(() {
                        _jobRequests.remove(item);
                      });
                    },
                    isFavourite: true,
                  );
                }

                /// ---------------- Booking Card ----------------
                if (item is FixxerBookingModel) {
                  return FixxerBookingCard(
                    booking: item,
                    onTap: () {
                      Get.to(() => const FixxerJobDetailScreen());
                    },
                    onRemove: () {
                      setState(() {
                        _bookings.remove(item);
                      });
                    },
                    alwaysFavourite: true,
                    onFavouriteToggle: null,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
    );
  }
}
