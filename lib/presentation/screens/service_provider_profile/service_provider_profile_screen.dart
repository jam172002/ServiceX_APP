import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/fixer_model.dart';
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
  // Read fixer from Get.arguments — null-safe, falls back to dummy data
  FixerModel? get fixer => Get.arguments is FixerModel ? Get.arguments as FixerModel : null;

  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastOffset = 0;
  bool isFavourite = false;

  // Resolved subcategory names (IDs → names via Firestore)
  List<String> _subcategoryNames = [];
  // Resolved main category name
  String _categoryName = '';

  Future<void> _resolveNames(FixerModel f) async {
    try {
      // Fetch category name + all subcategory names in parallel
      final futures = <Future>[];

      // Category
      futures.add(
        FirebaseFirestore.instance
            .collection('service_categories')
            .doc(f.mainCategory)
            .get()
            .then((doc) {
          if (doc.exists && mounted) {
            setState(() =>
            _categoryName = (doc.data()?['name'] ?? f.mainCategory) as String);
          }
        }),
      );

      // Subcategories
      if (f.subCategories.isNotEmpty) {
        futures.add(
          Future.wait(
            f.subCategories.map((id) => FirebaseFirestore.instance
                .collection('service_subcategories')
                .doc(id)
                .get()),
          ).then((docs) {
            final names = docs
                .where((d) => d.exists)
                .map((d) => (d.data()?['name'] ?? d.id) as String)
                .toList();
            if (mounted) setState(() => _subcategoryNames = names);
          }),
        );
      }

      await Future.wait(futures);
    } catch (_) {
      // silent fallback — IDs remain visible
    }
  }

  void toggleFavourite() {
    setState(() => isFavourite = !isFavourite);
    Get.dialog(
      SimpleDialogWidget(
        message: isFavourite ? 'Added to Favourites' : 'Removed from Favourites',
        icon: isFavourite ? Icons.favorite : Icons.favorite_border,
        iconColor: Colors.redAccent,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final f = fixer;
    if (f != null) _resolveNames(f);
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
    final f = fixer;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Header — real banner/avatar/name/location from FixerModel
                ServiceProviderProfileHeader(
                  bannerUrl: f?.bannerImageUrl,
                  avatarUrl: f?.profileImageUrl,
                  name: f?.fullName ?? 'Muhammad Sufyan',
                  location: f?.address.isNotEmpty == true
                      ? f!.address
                      : 'Location not set',
                ),
                const SizedBox(height: 75),

                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Rate / Category / Experience ─────────────
                        Row(
                          children: [
                            Text(
                              '\$${f?.hourlyRate.toStringAsFixed(0) ?? '–'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '/hour',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: XColors.black,
                                  fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(width: 12),
                            Container(height: 10, width: 1.5, color: XColors.primary),
                            const SizedBox(width: 12),
                            // Resolved category name (falls back to ID while loading)
                            Text(
                              _categoryName.isNotEmpty
                                  ? _categoryName
                                  : (f?.mainCategory ?? '–'),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: XColors.black,
                                  fontWeight: FontWeight.w300),
                            ),
                            if (f != null && f.yearsOfExperience > 0) ...[
                              const SizedBox(width: 12),
                              Container(height: 10, width: 1.5, color: XColors.primary),
                              const SizedBox(width: 12),
                              Text(
                                '${f.yearsOfExperience} ${f.yearsOfExperience == 1 ? 'Year' : 'Years'} of Experience',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: XColors.black,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ── Available days ────────────────────────────
                        if (f != null && f.availableDays.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: [
                              ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                  .map((day) {
                                final isAvailable = f.availableDays.any(
                                      (d) => d.toLowerCase().startsWith(
                                    day.toLowerCase().substring(0, 3),
                                  ),
                                );
                                return WorkingDayContainer(
                                  day: day,
                                  backgroundColor: isAvailable
                                      ? Colors.green
                                      : Colors.black54,
                                );
                              }),
                            ],
                          )
                        else
                        // Fallback when no fixer data
                          Wrap(
                            spacing: 8,
                            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                                .map((d) => WorkingDayContainer(day: d))
                                .toList(),
                          ),

                        const SizedBox(height: 6),

                        // ── Languages ─────────────────────────────────
                        Row(
                          children: [
                            const Text(
                              'Languages Spoken:',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: XColors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              f != null && f.languages.isNotEmpty
                                  ? f.languages.join(', ')
                                  : '–',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: XColors.black,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Bio ───────────────────────────────────────
                        const Text(
                          'Bio',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        ExpandableText(
                          text: f?.bio.isNotEmpty == true
                              ? f!.bio
                              : 'No bio provided.',
                          maxLines: 2,
                        ),

                        const SizedBox(height: 20),

                        // ── Specializations ───────────────────────────
                        if (f != null && f.subCategories.isNotEmpty)
                          ExpandableChips(
                            title: 'Specializes',
                            items: _subcategoryNames.isNotEmpty
                                ? _subcategoryNames
                                : f.subCategories, // fallback to IDs while loading
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

          // ── Back + Favourite ────────────────────────────────────
          Positioned(
            top: kToolbarHeight,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    decoration: BoxDecoration(
                      color: XColors.lightTint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.black87, size: 20),
                  ),
                ),
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
            onPressed: () =>
                Get.to(() => SingleChatScreen(isServiceProvider: false)),
            child: const Icon(Iconsax.sms5, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── WorkingDayContainer ───────────────────────────────────────────
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