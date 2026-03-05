import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/simple_alert_dialog.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_profile_header.dart';
import 'package:servicex_client_app/presentation/widgets/expandable_text.dart';
import 'package:servicex_client_app/presentation/widgets/expandable_chips_container.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_profile_bottom_section.dart';
import 'package:servicex_client_app/presentation/screens/chat/single_chat_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastOffset = 0;

  // Favourite state
  bool isFavourite = false;

  void toggleFavourite() {
    setState(() => isFavourite = !isFavourite);

    Get.dialog(
      SimpleDialogWidget(
        message: isFavourite
            ? 'Added to Favourites'
            : 'Removed from Favourites',
        icon: isFavourite ? Icons.favorite : Icons.favorite_border,
        iconColor: Colors.redAccent,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    const double sensitivity = 8;

    _scrollController.addListener(() {
      final offset = _scrollController.position.pixels;
      final diff = offset - _lastOffset;

      if (diff > sensitivity && _isFabVisible) {
        setState(() => _isFabVisible = false);
      } else if (diff < -sensitivity && !_isFabVisible) {
        setState(() => _isFabVisible = true);
      }

      _lastOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                ServiceProviderProfileHeader(),
                const SizedBox(height: 75),

                // Content
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            //? Service Catagory + Hourly Rate + Years of Experience
                            Row(
                              children: [
                                Text(
                                  '\$20',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '/hour',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: XColors.black,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  height: 10,
                                  width: 1.5,
                                  color: XColors.primary,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Electrican',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: XColors.black,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  height: 10,
                                  width: 1.5,
                                  color: XColors.primary,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '13 Years of Experience',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: XColors.black,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 6),
                            //? Working Days
                            Row(
                              children: [
                                WorkingDayContainer(day: 'Mon'),
                                WorkingDayContainer(day: 'Tue'),
                                WorkingDayContainer(day: 'Wed'),
                                WorkingDayContainer(day: 'Thr'),
                                WorkingDayContainer(day: 'Fri'),
                                WorkingDayContainer(
                                  day: 'Sat',
                                  backgroundColor: Colors.black54,
                                ),
                                WorkingDayContainer(
                                  day: 'Sun',
                                  backgroundColor: Colors.black54,
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            //? Languages Spoken
                            Row(
                              children: [
                                const Text(
                                  'Languages Spoken:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: XColors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                SizedBox(width: 12),
                                Text(
                                  'English, Franch',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: XColors.black,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),

                        const ExpandableText(
                          text:
                              'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam...',
                          maxLines: 2,
                        ),

                        const SizedBox(height: 20),

                        const ExpandableChips(
                          title: 'Specializes',
                          items: [
                            'Furniture Assembly',
                            'Closets & Cabinets',
                            'Custom Woodwork',
                            'Door & Window Fixing',
                            'Painting',
                            'Closets & Cabinets',
                          ],
                        ),
                        const SizedBox(height: 20),
                        const ExpandableChips(
                          title: 'Service Locations',
                          items: [
                            'Model Town A',
                            'DHA Phase 2',
                            'Goheir Town',
                            'Shadab Colony',
                            'Husaini Chowk',
                            'Satellite Town',
                          ],
                        ),

                        const SizedBox(height: 20),

                        const ServiceProviderProfileBottomSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky top icons (Back + Favourite)
          Positioned(
            top: kToolbarHeight,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    decoration: BoxDecoration(
                      color: XColors.lightTint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),

                // Favourite button
                GestureDetector(
                  onTap: toggleFavourite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: XColors.lightTint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isFavourite ? Icons.favorite : Iconsax.heart,
                      color: isFavourite ? Colors.redAccent : Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // FAB with slide + fade animation
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isFabVisible ? 1 : 0,
          child: FloatingActionButton(
            backgroundColor: XColors.primary,
            shape: const OvalBorder(),
            elevation: 0,
            onPressed: () {
              Get.to(() => SingleChatScreen(isServiceProvider: false));
            },
            child: const Icon(Iconsax.sms5, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class WorkingDayContainer extends StatelessWidget {
  final String day;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;

  const WorkingDayContainer({
    super.key,
    required this.day,
    this.backgroundColor = Colors.green,
    this.textColor = Colors.white,
    this.fontSize = 8,
    this.padding = const EdgeInsets.all(4),
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          day,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
