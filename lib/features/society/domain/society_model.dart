import 'package:equatable/equatable.dart';

class SocietyDirectoryEntry extends Equatable {
  final String id;
  final String name; // e.g. "Gokuldham Co-op Society", "Silver Oak Heights"
  final String locality;
  final String city;
  final String pincode;
  final int activeWorkersCount;
  final List<String> availableCategories; // ['maid', 'milkman', 'watchman', 'cleaner']

  const SocietyDirectoryEntry({
    required this.id,
    required this.name,
    required this.locality,
    required this.city,
    required this.pincode,
    required this.activeWorkersCount,
    required this.availableCategories,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'locality': locality,
        'city': city,
        'pincode': pincode,
        'active_workers_count': activeWorkersCount,
        'available_categories': availableCategories,
      };

  factory SocietyDirectoryEntry.fromJson(Map<String, dynamic> json) {
    return SocietyDirectoryEntry(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      locality: json['locality'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      activeWorkersCount: json['active_workers_count'] as int? ?? 0,
      availableCategories: List<String>.from(json['available_categories'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, locality, pincode, activeWorkersCount];
}
