import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../theme/app_colors.dart';

class AppNotifier {
  static String? _lastMessage;
  static DateTime? _lastMessageTime;

  static bool _shouldThrottle(String message) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastMessageTime != null &&
        now.difference(_lastMessageTime!).inSeconds < 2) {
      return true;
    }
    _lastMessage = message;
    _lastMessageTime = now;
    return false;
  }

  static void showSuccess(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_shouldThrottle(title)) return;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: duration,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
      primaryColor: AppColors.success,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_shouldThrottle(title)) return;
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: duration,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.info_outline_rounded, color: AppColors.info),
      primaryColor: AppColors.info,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (_shouldThrottle(title)) return;
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: duration,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
      primaryColor: AppColors.warning,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  static void showError(
    BuildContext context, {
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (_shouldThrottle(title)) return;
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: duration,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
      primaryColor: AppColors.error,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }
}
