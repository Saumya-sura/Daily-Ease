import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/bookings/presentation/consumer_bookings_screen.dart';
import '../../features/bookings/presentation/create_booking_screen.dart';
import '../../features/custom_requests/presentation/custom_request_screen.dart';
import '../../features/discovery/presentation/consumer_home_screen.dart';
import '../../features/onboarding/presentation/provider_onboarding_screen.dart';
import '../../features/onboarding/presentation/role_select_screen.dart';
import '../../features/profile/presentation/consumer_profile_screen.dart';
import '../../features/provider/presentation/provider_dashboard_screen.dart';
import '../../features/provider/presentation/provider_detail_screen.dart';
import '../../features/household_tracker/presentation/household_bill_tracker_screen.dart';
import '../../features/society/presentation/society_directory_screen.dart';
import 'consumer_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Welcome / Role Selection Screen
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectScreen(),
    ),

    // Provider Dynamic Onboarding Screen
    GoRoute(
      path: '/provider/onboarding',
      builder: (context, state) => const ProviderOnboardingScreen(),
    ),

    // Provider Pro Dashboard
    GoRoute(
      path: '/provider/dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),

    // Consumer Tabs Shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ConsumerShell(child: child),
      routes: [
        GoRoute(
          path: '/consumer/home',
          builder: (context, state) => const ConsumerHomeScreen(),
        ),
        GoRoute(
          path: '/consumer/bookings',
          builder: (context, state) => const ConsumerBookingsScreen(),
        ),
        GoRoute(
          path: '/consumer/society-directory',
          builder: (context, state) => const SocietyDirectoryScreen(),
        ),
        GoRoute(
          path: '/consumer/profile',
          builder: (context, state) => const ConsumerProfileScreen(),
        ),
      ],
    ),

    // Provider Detail Screen
    GoRoute(
      path: '/provider-details/:providerId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final providerId = state.pathParameters['providerId'] ?? '';
        return ProviderDetailScreen(providerId: providerId);
      },
    ),

    // Create Booking Screen
    GoRoute(
      path: '/book-service/:providerId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final providerId = state.pathParameters['providerId'] ?? '';
        return CreateBookingScreen(providerId: providerId);
      },
    ),

    // Custom Request Screen
    GoRoute(
      path: '/consumer/custom-request',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CustomRequestScreen(),
    ),

    // Household Attendance & Bill Tracker
    GoRoute(
      path: '/consumer/household-tracker',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HouseholdBillTrackerScreen(),
    ),
  ],
);
