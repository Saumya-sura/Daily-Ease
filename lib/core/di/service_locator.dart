import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/bookings/data/booking_repository.dart';
import '../../features/custom_requests/data/custom_request_repository.dart';
import '../../features/discovery/data/discovery_repository.dart';
import '../../features/reviews/data/review_repository.dart';
import '../config/supabase_config.dart';
import '../network/network_info.dart';
import '../storage/hive_storage_service.dart';
import '../utils/app_logger.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  AppLogger.info('ServiceLocator', 'Initializing core dependencies and repositories');

  // 1. Storage
  final storageService = HiveStorageService();
  await storageService.init();
  sl.registerSingleton<HiveStorageService>(storageService);

  // 2. Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // 3. Supabase Client
  if (SupabaseConfig.isLiveConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
      sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
      AppLogger.info('ServiceLocator', 'Supabase client initialized with live backend');
    } catch (e) {
      AppLogger.warning('ServiceLocator', 'Failed to initialize live Supabase, using mock mode: $e');
    }
  } else {
    AppLogger.info('ServiceLocator', 'Supabase running in offline-first mode.');
  }

  // 4. Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<DiscoveryRepository>(() => DiscoveryRepositoryImpl(sl()));
  sl.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(sl()));
  sl.registerLazySingleton<CustomRequestRepository>(() => CustomRequestRepositoryImpl());
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl());

  AppLogger.info('ServiceLocator', 'All repositories registered successfully');
}
