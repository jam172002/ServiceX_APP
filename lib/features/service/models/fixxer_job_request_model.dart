import 'package:servicex_client_app/utils/constants/enums.dart';

class FixxerJobRequestModel {
  final String clientName;
  final String serviceTitle;
  final String description;
  final List<String> images;
  final DateTime dateTime;
  final String location;
  final int minBudget;
  final int maxBudget;
  final FixxerJobRequestType type;

  String status;

  bool isFavourite;

  FixxerJobRequestModel({
    required this.clientName,
    required this.serviceTitle,
    required this.description,
    required this.images,
    required this.dateTime,
    required this.location,
    required this.minBudget,
    required this.maxBudget,
    required this.type,
    this.status = "booked",
    this.isFavourite = false,
  });
}
