import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/app_router.dart';
import 'core/network/network_info.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/offline_banner.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/bookings/data/booking_repository.dart';
import 'features/bookings/presentation/bloc/booking_bloc.dart';
import 'features/discovery/data/discovery_repository.dart';
import 'features/discovery/presentation/bloc/discovery_bloc.dart';
import 'features/localization/locale_cubit.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('AppMain', 'Starting Daily-Ease application bootstrap');

  await initServiceLocator();

  runApp(const DailyEaseApp());
}

class DailyEaseApp extends StatelessWidget {
  const DailyEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(sl()),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(sl()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(sl<AuthRepository>())..add(AuthCheckRequested()),
        ),
        BlocProvider<DiscoveryBloc>(
          create: (_) => DiscoveryBloc(sl<DiscoveryRepository>()),
        ),
        BlocProvider<BookingBloc>(
          create: (_) => BookingBloc(sl<BookingRepository>()),
        ),
      ],
      child: const DailyEaseAppView(),
    );
  }
}

class DailyEaseAppView extends StatelessWidget {
  const DailyEaseAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final networkInfo = sl<NetworkInfo>();

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Daily-Ease',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: appRouter,
        builder: (context, child) {
          return StreamBuilder<bool>(
            stream: networkInfo.onConnectivityChanged,
            initialData: true,
            builder: (context, snapshot) {
              final isOnline = snapshot.data ?? true;
              return Column(
                children: [
                  OfflineBanner(isOffline: !isOnline),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
