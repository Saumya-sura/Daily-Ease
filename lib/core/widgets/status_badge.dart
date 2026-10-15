import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BookingStatus {
  requested,
  accepted,
  declined,
  rescheduled,
  completed,
  cancelled,
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isVerifiedBadge;

  const StatusBadge({
    super.key,
    required this.status,
    this.isVerifiedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerifiedBadge) {
      final isVerified = status.toLowerCase() == 'verified';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isVerified ? AppColors.infoLight : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isVerified ? AppColors.verifiedBlue : AppColors.unverifiedGrey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified_rounded : Icons.shield_outlined,
              size: 14,
              color: isVerified ? AppColors.verifiedBlue : AppColors.unverifiedGrey,
            ),
            const SizedBox(width: 4),
            Text(
              isVerified ? 'Verified' : 'Self-Listed',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isVerified ? AppColors.verifiedBlue : AppColors.unverifiedGrey,
              ),
            ),
          ],
        ),
      );
    }

    final (color, bgColor, text) = switch (status.toLowerCase()) {
      'requested' || 'pending' => (
          AppColors.statusRequested,
          AppColors.warningLight,
          'Requested',
        ),
      'accepted' => (
          AppColors.statusAccepted,
          AppColors.infoLight,
          'Accepted',
        ),
      'declined' || 'rejected' => (
          AppColors.statusDeclined,
          AppColors.errorLight,
          'Declined',
        ),
      'rescheduled' => (
          AppColors.statusRescheduled,
          const Color(0xFFF3E8FF),
          'Rescheduled',
        ),
      'completed' => (
          AppColors.statusCompleted,
          AppColors.successLight,
          'Completed',
        ),
      'cancelled' => (
          AppColors.statusCancelled,
          const Color(0xFFF1F5F9),
          'Cancelled',
        ),
      _ => (
          AppColors.textSecondaryLight,
          const Color(0xFFF1F5F9),
          status,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
