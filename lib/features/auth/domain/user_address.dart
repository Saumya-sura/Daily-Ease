import 'package:equatable/equatable.dart';

enum AddressType { home, office, hostel, other }

class UserAddress extends Equatable {
  final String id;
  final String label; // 'Home', 'Office', 'Hostel', etc.
  final AddressType type;
  final String societyOrBuilding;
  final String flatOrRoom;
  final String locality;
  final String city;
  final String pincode;
  final bool isPrimary;

  const UserAddress({
    required this.id,
    required this.label,
    required this.type,
    required this.societyOrBuilding,
    required this.flatOrRoom,
    required this.locality,
    required this.city,
    required this.pincode,
    this.isPrimary = false,
  });

  String get fullAddress =>
      '$flatOrRoom, $societyOrBuilding, $locality, $city - $pincode';

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type.name,
        'society_or_building': societyOrBuilding,
        'flat_or_room': flatOrRoom,
        'locality': locality,
        'city': city,
        'pincode': pincode,
        'is_primary': isPrimary,
      };

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Home',
      type: AddressType.values.firstWhere(
        (t) => t.name == (json['type'] ?? 'home'),
        orElse: () => AddressType.home,
      ),
      societyOrBuilding: json['society_or_building'] as String? ?? '',
      flatOrRoom: json['flat_or_room'] as String? ?? '',
      locality: json['locality'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        type,
        societyOrBuilding,
        flatOrRoom,
        locality,
        city,
        pincode,
        isPrimary,
      ];
}
