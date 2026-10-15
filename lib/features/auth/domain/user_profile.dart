import 'package:equatable/equatable.dart';
import 'user_address.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String preferredLanguage; // 'en', 'hi', 'mr'
  final String role; // 'consumer' | 'provider'
  final String? avatarUrl;
  final List<UserAddress> addresses;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.preferredLanguage = 'en',
    required this.role,
    this.avatarUrl,
    this.addresses = const [],
  });

  bool get isProvider => role == 'provider';
  bool get isConsumer => role == 'consumer';

  UserAddress? get primaryAddress =>
      addresses.firstWhere((a) => a.isPrimary, orElse: () => addresses.isNotEmpty ? addresses.first : const UserAddress(id: '', label: '', type: AddressType.home, societyOrBuilding: '', flatOrRoom: '', locality: '', city: '', pincode: ''));

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'preferred_language': preferredLanguage,
        'role': role,
        'avatar_url': avatarUrl,
        'addresses': addresses.map((a) => a.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      phoneNumber: json['phone_number'] as String? ?? '',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      role: json['role'] as String? ?? 'consumer',
      avatarUrl: json['avatar_url'] as String?,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => UserAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        preferredLanguage,
        role,
        avatarUrl,
        addresses,
      ];
}
