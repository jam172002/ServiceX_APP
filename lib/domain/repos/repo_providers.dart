import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servicex_client_app/domain/repos/service_catalog_repo.dart';

//final servicesRepo = ServiceCatalogRepo(FirebaseFirestore.instance);
final ServiceCatalogRepo servicesRepo =
ServiceCatalogRepo(FirebaseFirestore.instance);