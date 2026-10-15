import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ServiceIconBadge extends StatelessWidget {
  final String categoryId;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ServiceIconBadge({
    super.key,
    required this.categoryId,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
  });

  static IconData getIconForCategory(String categoryId) {
    final normalized = categoryId.toLowerCase().trim();
    switch (normalized) {
      case 'maid':
      case 'househelp':
      case 'helper':
      case 'bai':
        return Icons.cleaning_services_rounded;
      case 'milkman':
      case 'milk':
      case 'dairy':
        return Icons.local_drink_rounded;
      case 'watchman':
      case 'security':
      case 'guard':
        return Icons.shield_rounded;
      case 'plumber':
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrician':
      case 'electrical':
        return Icons.bolt_rounded;
      case 'carpenter':
      case 'carpentry':
        return Icons.handyman_rounded;
      case 'cook':
      case 'chef':
      case 'cooking':
        return Icons.restaurant_rounded;
      case 'cleaner':
      case 'deep_cleaning':
        return Icons.sanitizer_rounded;
      case 'laundry':
      case 'ironing':
        return Icons.local_laundry_service_rounded;
      case 'gardener':
      case 'gardening':
        return Icons.yard_rounded;
      case 'appliance':
      case 'repair':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = getIconForCategory(categoryId);
    final isDark = theme.brightness == Brightness.dark;

    final bg = backgroundColor ??
        (isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight);
    final ic = iconColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.52,
          color: ic,
        ),
      ),
    );
  }
}
