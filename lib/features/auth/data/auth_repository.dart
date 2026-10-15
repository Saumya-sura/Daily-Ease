import 'dart:convert';
import '../../../core/config/supabase_config.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/user_address.dart';
import '../domain/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signIn(String email, String password);
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  });
  Future<UserProfile> switchRole(String newRole);
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<UserProfile> addAddress(UserAddress address);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final HiveStorageService _storageService;
  UserProfile? _currentUser;

  AuthRepositoryImpl(this._storageService) {
    _loadPersistedUser();
  }

  void _loadPersistedUser() {
    try {
      final cachedJson = _storageService.getCached(HiveBoxes.userSession, 'active_profile');
      if (cachedJson != null && cachedJson is String) {
        final Map<String, dynamic> data = jsonDecode(cachedJson);
        final profile = UserProfile.fromJson(data);
        if (profile.id == 'usr_consumer_demo' || profile.id == 'usr_provider_demo') {
          _currentUser = null;
          _storageService.deleteCached(HiveBoxes.userSession, 'active_profile');
        } else {
          _currentUser = profile;
          AppLogger.info('AuthRepo', 'Restored persisted user session', {'id': _currentUser?.id});
        }
      }
    } catch (e) {
      AppLogger.warning('AuthRepo', 'Could not restore user session: $e');
    }
  }

  Future<void> _persistCurrentUser() async {
    if (_currentUser != null) {
      await _storageService.putCached(
        HiveBoxes.userSession,
        'active_profile',
        jsonEncode(_currentUser!.toJson()),
      );
    } else {
      await _storageService.deleteCached(HiveBoxes.userSession, 'active_profile');
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    AppLogger.info('AuthRepo', 'Attempting user sign in', {'email': email});

    if (SupabaseConfig.isLiveConfigured) {
      // In live Supabase mode:
      // final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      // fetch profile from public.profiles
    }

    // In local persistent mode:
    _currentUser = UserProfile(
      id: 'usr_${email.hashCode.abs()}',
      email: email,
      fullName: email.split('@').first,
      phoneNumber: '',
      preferredLanguage: _storageService.getSelectedLocale(),
      role: 'consumer',
      addresses: const [],
    );

    await _storageService.setSavedRole(_currentUser!.role);
    await _persistCurrentUser();
    return _currentUser!;
  }

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  }) async {
    AppLogger.info('AuthRepo', 'Registering new user account', {
      'role': role,
      'fullName': fullName,
    });

    _currentUser = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      preferredLanguage: _storageService.getSelectedLocale(),
      role: role,
      addresses: const [],
    );

    await _storageService.setSavedRole(role);
    await _persistCurrentUser();
    return _currentUser!;
  }

  @override
  Future<UserProfile> switchRole(String newRole) async {
    AppLogger.info('AuthRepo', 'Switching user role', {'newRole': newRole});
    if (_currentUser == null) {
      // Create fresh user session for chosen role
      _currentUser = UserProfile(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@dailyease.local',
        fullName: 'Active User',
        phoneNumber: '',
        preferredLanguage: _storageService.getSelectedLocale(),
        role: newRole,
        addresses: const [],
      );
    } else {
      _currentUser = UserProfile(
        id: _currentUser!.id,
        email: _currentUser!.email,
        fullName: _currentUser!.fullName,
        phoneNumber: _currentUser!.phoneNumber,
        preferredLanguage: _currentUser!.preferredLanguage,
        role: newRole,
        avatarUrl: _currentUser!.avatarUrl,
        addresses: _currentUser!.addresses,
      );
    }

    await _storageService.setSavedRole(newRole);
    await _persistCurrentUser();
    return _currentUser!;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    _currentUser = profile;
    await _persistCurrentUser();
    return _currentUser!;
  }

  @override
  Future<UserProfile> addAddress(UserAddress address) async {
    if (_currentUser == null) {
      throw Exception('No active user logged in');
    }
    final updatedAddresses = List<UserAddress>.from(_currentUser!.addresses)..add(address);
    _currentUser = UserProfile(
      id: _currentUser!.id,
      email: _currentUser!.email,
      fullName: _currentUser!.fullName,
      phoneNumber: _currentUser!.phoneNumber,
      preferredLanguage: _currentUser!.preferredLanguage,
      role: _currentUser!.role,
      avatarUrl: _currentUser!.avatarUrl,
      addresses: updatedAddresses,
    );
    await _persistCurrentUser();
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    AppLogger.info('AuthRepo', 'User signed out');
    _currentUser = null;
    await _storageService.clearUserSession();
  }
}
