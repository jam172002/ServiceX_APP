import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../domain/models/service_category.dart';
import '../../domain/repos/service_catalog_repo.dart';

class CategoryController extends GetxController {
  final ServiceCatalogRepo _repo = ServiceCatalogRepo(FirebaseFirestore.instance);

  final RxList<ServiceCategory> categories = <ServiceCategory>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<ServiceCategory>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    isLoading.value = true;
    error.value = '';

    _sub?.cancel();
    _sub = _repo.watchCategories().listen(
          (data) {
        categories.assignAll(data);
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}