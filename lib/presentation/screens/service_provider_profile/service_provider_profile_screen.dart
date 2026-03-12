import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/controller/category_controller.dart';
import 'package:servicex_client_app/presentation/widgets/simple_alert_dialog.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_profile_header.dart';
import 'package:servicex_client_app/presentation/widgets/expandable_text.dart';
import 'package:servicex_client_app/presentation/widgets/expandable_chips_container.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_profile_bottom_section.dart';
import 'package:servicex_client_app/presentation/screens/chat/single_chat_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../../domain/models/fixer_model.dart';
import '../../../services/chat_notification_service.dart';
import '../chat/controller/chat_controller.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
  // Accept FixerModel from Get.arguments
  FixerModel? get fixxer =>
      Get.arguments is FixerModel ? Get.arguments as FixerModel : null;

  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastOffset = 0;
  bool isFavourite = false;
  bool _isChatLoading = false;

  // Resolved names from CategoryController (already loaded app-wide)
  String _categoryName = '';
  List<String> _subcategoryNames = [];

  // ── Resolve category/subcategory names ────────────────────────────────────

  void _resolveNames(FixerModel f) {
    // Use CategoryController which is already streaming — no extra Firestore calls
    try {
      final catCtrl = Get.find<CategoryController>();

      final catName = catCtrl.categoryName(f.mainCategory);

      final subNames = f.subCategories
          .map((id) => catCtrl.subcategoryName(id))
          .where((n) => n.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _categoryName = catName;
          _subcategoryNames = subNames;
        });
      }
    } catch (_) {
      // CategoryController not yet ready — names stay empty, IDs shown as fallback
    }
  }

  // ── Favourite toggle ──────────────────────────────────────────────────────

  void toggleFavourite() {
    setState(() => isFavourite = !isFavourite);
    Get.dialog(
      SimpleDialogWidget(
        message:
        isFavourite ? 'Added to Favourites' : 'Removed from Favourites',
        icon: isFavourite ? Icons.favorite : Icons.favorite_border,
        iconColor: Colors.redAccent,
      ),
    );
  }

  // ── Open chat ─────────────────────────────────────────────────────────────

  Future<void> _openChat() async {
    final f = fixxer;

    if (f == null || f.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider info not available')),
      );
      return;
    }

    setState(() => _isChatLoading = true);

    try {
      if (!Get.isRegistered<ChatController>()) {
        Get.put(ChatController());
      }

      final ctrl = Get.find<ChatController>();
      final myToken = await ChatNotificationService.instance.getToken();

      await ctrl.openChat(
        otherId: f.uid,
        otherName: f.fullName,
        otherAvatar: f.profileImageUrl,
        otherFcmToken: null,
        myFcmToken: myToken,
      );

      if (!mounted) return;

      Get.to(() => SingleChatScreen(
        conversationId: ctrl.activeConversationId.value,
        otherUserId: f.uid,
        otherUserName: f.fullName,
        otherUserAvatar: f.profileImageUrl,
        isServiceProvider: false,
      ));
    } catch (e, stack) {
      debugPrint('▶ CHAT ERROR: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChatLoading = false);
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final f = fixxer;
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final f = fixxer;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                ServiceProviderProfileHeader(
                  bannerUrl: f?.bannerImageUrl,
                  avatarUrl: f?.profileImageUrl,
                  name: f?.fullName ?? '–',
                  location: f?.location.address.isNotEmpty == true
                      ? f!.location.address
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
                        // ── Rate / Category row ───────────────────────────
                        Row(
                          children: [
                            if (f?.hourlyRate != null) ...[
                              Text(
                                'PKR ${f!.hourlyRate.toStringAsFixed(0)}',
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
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                  height: 10, width: 1.5, color: XColors.primary),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              _categoryName.isNotEmpty
                                  ? _categoryName
                                  : (f?.mainCategory ?? '–'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: XColors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ── Rating row ────────────────────────────────────
                        if (f != null) ...[
                          Row(
                            children: [
                              const Icon(Iconsax.star5,
                                  color: XColors.warning, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                f.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${f.totalReviews} ${f.totalReviews == 1 ? 'review' : 'reviews'})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: XColors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],

                        // ── Location row ──────────────────────────────────
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: XColors.grey, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                f?.location.address.isNotEmpty == true
                                    ? f!.location.address
                                    : 'Location not set',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: XColors.grey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ── Available days ────────────────────────────────
                        if (f != null && f.availableDays.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: [
                              ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                  .map((day) {
                                final isAvailable = f.availableDays.any(
                                      (d) => d.toLowerCase().startsWith(
                                    day.toLowerCase(),
                                  ),
                                );
                                return WorkingDayContainer(
                                  day: day,
                                  backgroundColor: isAvailable
                                      ? Colors.green
                                      : Colors.black26,
                                );
                              }),
                            ],
                          )
                        else
                          Wrap(
                            spacing: 8,
                            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                                .map((d) => WorkingDayContainer(day: d))
                                .toList(),
                          ),

                        const SizedBox(height: 6),

                        // ── Languages ─────────────────────────────────────
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
                            const SizedBox(width: 12),
                            Text(
                              f != null && f.languages.isNotEmpty
                                  ? f.languages.join(', ')
                                  : '–',
                              style: const TextStyle(
                                fontSize: 11,
                                color: XColors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Bio ───────────────────────────────────────────
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

                        // ── Specializations ───────────────────────────────
                        if (f != null && f.subCategories.isNotEmpty)
                          ExpandableChips(
                            title: 'Specializes',
                            items: _subcategoryNames.isNotEmpty
                                ? _subcategoryNames
                                : f.subCategories,
                          ),

                        const SizedBox(height: 20),

                        ServiceProviderProfileBottomSection(fixxer: f),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Back + Favourite buttons ──────────────────────────────────────
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

      // ── Chat FAB ──────────────────────────────────────────────────────────
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton(
            backgroundColor: XColors.primary,
            shape: const OvalBorder(),
            elevation: 0,
            onPressed: _isChatLoading ? null : _openChat,
            child: _isChatLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Icon(Iconsax.sms5, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── WorkingDayContainer ───────────────────────────────────────────────────────

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