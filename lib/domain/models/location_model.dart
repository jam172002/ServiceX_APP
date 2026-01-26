class LocationModel {
  final String label; // Home, Office, Custom
  final String address;
  final double lat;
  final double lng;
  final bool isDefault;

  const LocationModel({
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  LocationModel copyWith({
    String? label,
    String? address,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return LocationModel(
      label: label ?? this.label,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'address': address,
    'lat': lat,
    'lng': lng,
    'isDefault': isDefault,
  };

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      label: (json['label'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : double.tryParse('${json['lat']}') ?? 0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : double.tryParse('${json['lng']}') ?? 0,
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }
}
