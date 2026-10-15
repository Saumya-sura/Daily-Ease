import 'package:equatable/equatable.dart';

class CustomServiceRequest extends Equatable {
  final String id;
  final String consumerId;
  final String consumerName;
  final String consumerPhone;
  final String title;
  final String description;
  final String? photoUrl;
  final String locality;
  final String pincode;
  final double? budgetEstimate;
  final DateTime neededDate;
  final String neededTime;
  final int responsesCount;
  final String status; // 'open', 'assigned', 'closed'
  final DateTime createdAt;

  const CustomServiceRequest({
    required this.id,
    required this.consumerId,
    required this.consumerName,
    required this.consumerPhone,
    required this.title,
    required this.description,
    this.photoUrl,
    required this.locality,
    required this.pincode,
    this.budgetEstimate,
    required this.neededDate,
    required this.neededTime,
    this.responsesCount = 0,
    this.status = 'open',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'consumer_id': consumerId,
        'consumer_name': consumerName,
        'consumer_phone': consumerPhone,
        'title': title,
        'description': description,
        'photo_url': photoUrl,
        'locality': locality,
        'pincode': pincode,
        'budget_estimate': budgetEstimate,
        'needed_date': neededDate.toIso8601String(),
        'needed_time': neededTime,
        'responses_count': responsesCount,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  factory CustomServiceRequest.fromJson(Map<String, dynamic> json) {
    return CustomServiceRequest(
      id: json['id'] as String,
      consumerId: json['consumer_id'] as String? ?? '',
      consumerName: json['consumer_name'] as String? ?? 'Consumer',
      consumerPhone: json['consumer_phone'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      locality: json['locality'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      budgetEstimate: (json['budget_estimate'] as num?)?.toDouble(),
      neededDate: DateTime.tryParse(json['needed_date'] ?? '') ?? DateTime.now(),
      neededTime: json['needed_time'] as String? ?? 'Flexible',
      responsesCount: json['responses_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        consumerId,
        title,
        locality,
        pincode,
        budgetEstimate,
        status,
        responsesCount,
      ];
}
