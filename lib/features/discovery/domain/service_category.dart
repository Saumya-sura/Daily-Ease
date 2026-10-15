import 'package:equatable/equatable.dart';

class ServiceCategory extends Equatable {
  final String id;
  final String nameEn;
  final String nameHi;
  final String nameMr;
  final String iconName;
  final List<String> searchAliases;
  final List<CategoryFormField> dynamicFields;
  final List<String> supportedBillingModels;

  const ServiceCategory({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.nameMr,
    required this.iconName,
    required this.searchAliases,
    required this.dynamicFields,
    required this.supportedBillingModels,
  });

  String localizedName(String locale) {
    switch (locale) {
      case 'hi':
        return nameHi;
      case 'mr':
        return nameMr;
      default:
        return nameEn;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_hi': nameHi,
        'name_mr': nameMr,
        'icon_name': iconName,
        'search_aliases': searchAliases,
        'supported_billing_models': supportedBillingModels,
      };

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameHi: json['name_hi'] as String,
      nameMr: json['name_mr'] as String,
      iconName: json['icon_name'] as String,
      searchAliases: List<String>.from(json['search_aliases'] ?? []),
      dynamicFields: (json['dynamic_fields'] as List<dynamic>?)
              ?.map((e) => CategoryFormField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      supportedBillingModels: List<String>.from(json['supported_billing_models'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, nameEn, nameHi, nameMr, iconName, searchAliases];
}

class CategoryFormField extends Equatable {
  final String key;
  final String label;
  final String fieldType; // 'multiselect', 'dropdown', 'text', 'number', 'boolean'
  final List<String> options;
  final bool isRequired;

  const CategoryFormField({
    required this.key,
    required this.label,
    required this.fieldType,
    required this.options,
    this.isRequired = true,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'field_type': fieldType,
        'options': options,
        'is_required': isRequired,
      };

  factory CategoryFormField.fromJson(Map<String, dynamic> json) {
    return CategoryFormField(
      key: json['key'] as String,
      label: json['label'] as String,
      fieldType: json['field_type'] as String,
      options: List<String>.from(json['options'] ?? []),
      isRequired: json['is_required'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [key, label, fieldType, options, isRequired];
}
