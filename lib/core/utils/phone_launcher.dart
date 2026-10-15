import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_logger.dart';
import 'app_notifier.dart';

class PhoneLauncher {
  /// Launches the native phone dialer with sanitized phone number.
  /// Handles missing phone numbers, non-telephony devices (tablets/emulators), and errors gracefully.
  static Future<bool> makePhoneCall(
    BuildContext context, {
    required String? rawPhoneNumber,
    required String recipientName,
  }) async {
    if (rawPhoneNumber == null || rawPhoneNumber.trim().isEmpty) {
      AppLogger.warning('PhoneLauncher', 'Call attempted with empty phone number');
      if (context.mounted) {
        AppNotifier.showWarning(
          context,
          title: 'Phone Number Unavailable',
          description: 'This provider has not configured a direct calling number.',
        );
      }
      return false;
    }

    // Clean digits, retaining '+' prefix if international
    final cleanNumber = rawPhoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri callUri = Uri(scheme: 'tel', path: cleanNumber);

    AppLogger.info('PhoneLauncher', 'Launching dialer for recipient', {
      'recipient': recipientName,
    });

    try {
      if (await canLaunchUrl(callUri)) {
        final success = await launchUrl(callUri, mode: LaunchMode.externalApplication);
        if (!success && context.mounted) {
          AppNotifier.showError(
            context,
            title: 'Call Failed',
            description: 'Could not open the device phone dialer.',
          );
        }
        return success;
      } else {
        AppLogger.warning('PhoneLauncher', 'Device cannot handle tel: scheme');
        if (context.mounted) {
          AppNotifier.showWarning(
            context,
            title: 'Unsupported Device',
            description: 'This device does not support direct phone calls.',
          );
        }
        return false;
      }
    } catch (e, st) {
      AppLogger.error('PhoneLauncher', 'Exception launching phone dialer', error: e, stackTrace: st);
      if (context.mounted) {
        AppNotifier.showError(
          context,
          title: 'Error',
          description: 'An unexpected error occurred while launching phone dialer.',
        );
      }
      return false;
    }
  }

  /// Opens direct WhatsApp chat with a pre-filled contextual message.
  /// Free, instant, zero API fees. Falls back gracefully if WhatsApp is not installed.
  static Future<bool> openWhatsApp(
    BuildContext context, {
    required String? rawPhoneNumber,
    required String recipientName,
    String? prefilledMessage,
  }) async {
    if (rawPhoneNumber == null || rawPhoneNumber.trim().isEmpty) {
      AppLogger.warning('PhoneLauncher', 'WhatsApp attempted with empty phone number');
      if (context.mounted) {
        AppNotifier.showWarning(
          context,
          title: 'Number Unavailable',
          description: 'This contact does not have a valid WhatsApp phone number.',
        );
      }
      return false;
    }

    // Clean digits
    var cleanNumber = rawPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber'; // Add India country code prefix if 10-digit
    }

    final message = prefilledMessage ?? 'Hello $recipientName, I found your profile on Daily-Ease.';
    final Uri waUri = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');

    AppLogger.info('PhoneLauncher', 'Opening WhatsApp for recipient', {
      'recipient': recipientName,
      'number': cleanNumber,
    });

    try {
      final success = await launchUrl(waUri, mode: LaunchMode.externalApplication);
      if (!success && context.mounted) {
        AppNotifier.showError(
          context,
          title: 'Could Not Open WhatsApp',
          description: 'Please ensure WhatsApp is installed or use Direct Calling.',
        );
      }
      return success;
    } catch (e, st) {
      AppLogger.error('PhoneLauncher', 'Exception launching WhatsApp', error: e, stackTrace: st);
      if (context.mounted) {
        AppNotifier.showError(
          context,
          title: 'Error',
          description: 'An unexpected error occurred while opening WhatsApp.',
        );
      }
      return false;
    }
  }
}
