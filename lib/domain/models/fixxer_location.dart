class FixxerLocation {
  final String address;
  final double lat;
  final double lng;

  const FixxerLocation({
    required this.address,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toMap() => {
    'address': address,
    'lat': lat,
    'lng': lng,
  };

  factory FixxerLocation.fromMap(Map<String, dynamic> map) => FixxerLocation(
    address: (map['address'] ?? '') as String,
    lat: (map['lat'] ?? 0.0).toDouble(),
    lng: (map['lng'] ?? 0.0).toDouble(),
  );
}