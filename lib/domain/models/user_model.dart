import '../../core/utils/firestore_serializers.dart';
import '../enums/app_enums.dart';
import 'location_model.dart';

class UserModel {
  final String id;
  final AppRole role; // user | provider
  final String name;
  final String email;
  final String phone;
  final Gender gender;
  final LocationModel? location;
  final String photoUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.location,
    required this.photoUrl,
    required this.isVerified,
    required this.createdAt,
  });

  UserModel copyWith({
    AppRole? role,
    String? name,
    String? email,
    String? phone,
    Gender? gender,
    LocationModel? location,
    String? photoUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': enumToString(role),
    'name': name,
    'email': email,
    'phone': phone,
    'gender': enumToString(gender),
    'location': location?.toJson(),
    'photoUrl': photoUrl,
    'isVerified': isVerified,
    'createdAt': FirestoreSerializers.timestampFromDateTime(createdAt),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleRaw = (json['role'] ?? 'user').toString();
    final genderRaw = (json['gender'] ?? 'other').toString();

    return UserModel(
      id: (json['id'] ?? '').toString(),
      role: enumFromString<AppRole>(AppRole.values, roleRaw, AppRole.user),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      gender: enumFromString<Gender>(Gender.values, genderRaw, Gender.other),
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(
              FirestoreSerializers.toMap(json['location']),
            ),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      isVerified: (json['isVerified'] as bool?) ?? false,
      createdAt:
          FirestoreSerializers.dateTimeFrom(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
