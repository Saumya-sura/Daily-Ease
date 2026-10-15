import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_ease/core/config/service_categories_catalog.dart';
import 'package:daily_ease/core/widgets/service_icon_badge.dart';
import 'package:daily_ease/core/widgets/status_badge.dart';

void main() {
  group('Daily-Ease Core Unit & Widget Tests', () {
    test('ServiceCategoriesCatalog has all core service categories', () {
      expect(ServiceCategoriesCatalog.defaultCategories.length, greaterThanOrEqualTo(8));
      final maidCategory = ServiceCategoriesCatalog.defaultCategories.firstWhere((c) => c.id == 'maid');
      expect(maidCategory.nameEn, 'Maid / Helper');
      expect(maidCategory.searchAliases, contains('bai'));
      expect(maidCategory.searchAliases, contains('कामवाली'));
    });

    test('ServiceIconBadge resolves correct icons and safe fallback', () {
      expect(
        ServiceIconBadge.getIconForCategory('maid'),
        Icons.cleaning_services_rounded,
      );
      expect(
        ServiceIconBadge.getIconForCategory('milkman'),
        Icons.local_drink_rounded,
      );
      expect(
        ServiceIconBadge.getIconForCategory('watchman'),
        Icons.shield_rounded,
      );
      expect(
        ServiceIconBadge.getIconForCategory('plumber'),
        Icons.plumbing_rounded,
      );
      // Fallback
      expect(
        ServiceIconBadge.getIconForCategory('unknown_trade_xyz'),
        Icons.miscellaneous_services_rounded,
      );
    });

    testWidgets('StatusBadge renders verified badge and booking states', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: 'verified', isVerifiedBadge: true),
                StatusBadge(status: 'unverified', isVerifiedBadge: true),
                StatusBadge(status: 'requested'),
                StatusBadge(status: 'accepted'),
                StatusBadge(status: 'completed'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Self-Listed'), findsOneWidget);
      expect(find.text('Requested'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('ServiceIconBadge widget renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServiceIconBadge(categoryId: 'maid', size: 48),
          ),
        ),
      );

      expect(find.byType(ServiceIconBadge), findsOneWidget);
      expect(find.byIcon(Icons.cleaning_services_rounded), findsOneWidget);
    });
  });
}
