import 'dart:async';
import 'package:get/get.dart';
import 'package:servicex_client_app/domain/models/service_category.dart';
import 'package:servicex_client_app/domain/models/service_subcategory.dart';

import '../../domain/repos/repo_providers.dart';

class XSearchController extends GetxController {
  RxString searchQuery = ''.obs;

  final RxList<ServiceCategory> _cats = <ServiceCategory>[].obs;
  final RxList<ServiceSubcategory> _subs = <ServiceSubcategory>[].obs;

// keep providers in same format your UI already expects
  final RxList<Map<String, dynamic>> _providers = <Map<String, dynamic>>[].obs;
  StreamSubscription? _cSub;
  StreamSubscription? _sSub;

  @override
  void onInit() {
    super.onInit();

    _cSub = servicesRepo.watchCategories().listen((data) => _cats.assignAll(data));
    _sSub = servicesRepo.watchAllSubcategories().listen((data) => _subs.assignAll(data));

    // ✅ TEMP: keep dummy providers until you connect real provider repo
    _providers.assignAll([
      {'name': 'Ali Services', 'image': 'assets/images/service-provider.jpg'},
      {'name': 'Ahmed Cleaners', 'image': 'assets/images/service-provider.jpg'},
    ]);
  }

  @override
  void onClose() {
    _cSub?.cancel();
    _sSub?.cancel();
    super.onClose();
  }

  List<ServiceCategory> get filteredCategories {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _cats.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<ServiceSubcategory> get filteredSubcategories {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _subs.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  ServiceCategory? categoryById(String id) {
    try {
      return _cats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }


  List<ServiceSubcategory> get filteredServices {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _subs.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

/*  // ✅ so SearchScreen can call controller.filteredServices
  List<ServiceSubcategory> get filteredServices {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _subs.where((s) => s.name.toLowerCase().contains(q)).toList();
  }*/

  // ✅ so SearchScreen can call controller.filteredProviders
  List<Map<String, dynamic>> get filteredProviders {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _providers
        .where((p) => (p['name'] ?? '').toString().toLowerCase().contains(q))
        .toList();
  }


}