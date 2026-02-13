import 'dart:async';
import 'package:get/get.dart';
import '../../domain/repos/category_repository.dart';
import '../../domain/models/service_category_model.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repo;
  CategoryController({required CategoryRepository repo}) : _repo = repo;

  final RxList<ServiceCategoryModel> categories = <ServiceCategoryModel>[].obs;
  StreamSubscription<List<ServiceCategoryModel>>? _sub;

  void bindCategories() {
    _sub?.cancel();
    _sub = _repo.watchAllCategories().listen((list) {
      categories.assignAll(list);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
