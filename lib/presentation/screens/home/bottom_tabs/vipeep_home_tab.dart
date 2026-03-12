import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:servicex_client_app/presentation/widgets/custom_home_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/location_bottom_sheet.dart';
import 'package:servicex_client_app/presentation/widgets/map_view_container.dart';
import 'package:servicex_client_app/presentation/widgets/simple_heading.dart';
import 'package:servicex_client_app/presentation/controllers/location_controller.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/all_catagories_screen.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/create_job_screen.dart';
import 'package:servicex_client_app/presentation/screens/home/notifications_screen.dart';
import 'package:servicex_client_app/presentation/screens/home/search_screen.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/subcatagory_service_providers_screen.dart';
import 'package:servicex_client_app/presentation/widgets/category_listview.dart';
import 'package:servicex_client_app/presentation/widgets/populars_hor_listview.dart';
import 'package:servicex_client_app/presentation/widgets/service_providers_hor_view.dart';
import 'package:servicex_client_app/presentation/screens/profile/settings_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../../../domain/models/location_model.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../location/location_selector_screen.dart';
import 'controller/home_tab_controller.dart';

class VipeepHomeScreen extends StatefulWidget {
  const VipeepHomeScreen({super.key});

  @override
  State<VipeepHomeScreen> createState() => _VipeepHomeScreenState();
}

class _VipeepHomeScreenState extends State<VipeepHomeScreen> {
  final LocationController locationController = Get.find<LocationController>();
  final AuthController authController = Get.find<AuthController>();

  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();

    // Ensure HomeController is registered
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }

    // Ensure profile + location are synced once screen is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (authController.currentUser.value == null) {
        await authController.loadCurrentUser();
      }

      final u = authController.currentUser.value;
      if (u != null) {
        final profileLoc = u.location;
        if (locationController.currentLocation.value == null &&
            profileLoc!.address.trim().isNotEmpty) {
          await locationController.addLocation(profileLoc);
        }
      }

      // Trigger nearby fetch with the best available location
      final loc = locationController.currentLocation.value;
      if (loc != null) {
        Get.find<HomeController>().fetchNearbyFixxers(userLocation: loc);
      }
    });

    // Scroll listener for FAB hide/show
    const double sensitivity = 8;
    _scrollController.addListener(() {
      final offset = _scrollController.position.pixels;
      final diff = offset - _lastOffset;

      if (diff > sensitivity) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (diff < -sensitivity) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }

      _lastOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLocationTap(BuildContext context) async {
    final result = await showLocationBottomSheet(context);
    if (result == null) return;

    // 1) pick location on map
    if (result is String && result == "pick_on_map") {
      final picked =
      await Get.to<LocationModel>(() => const LocationSelectorScreen());
      if (picked != null && picked.address.trim().isNotEmpty) {
        await locationController.addLocation(picked);
        Get.find<HomeController>().fetchNearbyFixxers(userLocation: picked);
      }
      return;
    }

    // 2) bottom sheet returns LocationModel
    if (result is LocationModel) {
      await locationController.setDefaultLocation(result);
      Get.find<HomeController>().fetchNearbyFixxers(userLocation: result);
      return;
    }

    // 3) backward compat — string address
    if (result is String && result.trim().isNotEmpty) {
      final loc = LocationModel(
        label: "Home",
        address: result.trim(),
        lat: 0,
        lng: 0,
        isDefault: true,
      );
      await locationController.setDefaultLocation(loc);
      return;
    }

    Get.snackbar("Location", "Invalid selection");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: Obx(() {
          final u = authController.currentUser.value;
          return CustomHomeAppBar(
            name: u?.name ?? "Hi",
            location: locationController.currentLocation.value?.address ??
                "Select location",
            country: "Pakistan",
            imagePath: (u?.photoUrl != null && u!.photoUrl.trim().isNotEmpty)
                ? u.photoUrl
                : "assets/images/profile.png",
            onLocationTap: () => _handleLocationTap(context),
            onSettingTap: () => Get.to(() => SettingsScreen()),
            onNotificationTap: () => Get.to(() => NotificationsScreen()),
          );
        }),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // ── Search bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: GestureDetector(
                      onTap: () => Get.to(() => SearchScreen()),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.04),
                        decoration: BoxDecoration(
                          color: XColors.secondaryBG,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: XColors.borderColor, width: 0.7),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.search_normal,
                                color: XColors.success,
                                size: MediaQuery.of(context).size.width * 0.05),
                            SizedBox(
                                width:
                                MediaQuery.of(context).size.width * 0.02),
                            Flexible(
                              child: Text(
                                'Looking For ...',
                                style: TextStyle(
                                  color: XColors.grey,
                                  fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Categories heading ──────────────────────────────────
                  XHeading(
                    title: "Categories",
                    actionText: "See all",
                    onActionTap: () =>
                        Get.to(() => const AllCatagoriesScreen()),
                    sidePadding: 16,
                  ),
                  const SizedBox(height: 20),

                  // ── Categories list ─────────────────────────────────────
                  const CategoryListView(),
                  const SizedBox(height: 10),

                  // ── Banner ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AspectRatio(
                      aspectRatio: 3.2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/banner.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Populars heading ────────────────────────────────────
                  XHeading(
                    title: 'Populars',
                    actionText: 'See all',
                    onActionTap: () {},
                    showActionButton: false,
                    sidePadding: 16,
                  ),
                  const SizedBox(height: 15),

                  // ── Populars list (real data) ───────────────────────────
                  const PopularHomeHorizontalList(),
                  const SizedBox(height: 15),

                  // ── Near You heading ────────────────────────────────────
                  XHeading(
                    title: 'Near You',
                    actionText: 'See all',
                    sidePadding: 16,
                    onActionTap: () => Get.to(
                          () => const CatagoryServiceProviderScreen(
                          screenTitle: 'Near You', subcategoryId: ''),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ── Near You list (real data) ───────────────────────────
                  const ServiceProviderHorizontalList(),
                  const SizedBox(height: 20),

                  // ── Map ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const MapViewContainer(),
                  ),

                  const SizedBox(height: kBottomNavigationBarHeight + 40),
                ],
              ),
            ),
          ),

          // ── FAB ─────────────────────────────────────────────────────────
          Positioned(
            bottom: kBottomNavigationBarHeight + 40,
            right: 16,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isFabVisible ? 1 : 0,
                child: FloatingActionButton(
                  backgroundColor: XColors.primary,
                  shape: const OvalBorder(),
                  elevation: 0,
                  onPressed: () => Get.to(
                        () => CreateServiceJobScreen(
                        showServiceProviderCard: false),
                  ),
                  child: const Icon(Icons.work, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}