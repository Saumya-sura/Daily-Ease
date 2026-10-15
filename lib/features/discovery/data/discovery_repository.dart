import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/service_categories_catalog.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../provider/domain/provider_profile.dart';
import '../../society/domain/society_model.dart';
import '../domain/service_category.dart';

abstract class DiscoveryRepository {
  Future<List<ServiceCategory>> getCategories();
  Future<List<SocietyDirectoryEntry>> getSocieties();
  Future<List<ProviderProfile>> getProviders({
    String? categoryId,
    String? searchQuery,
    String? societyFilter,
    double? maxPrice,
    double? minRating,
    bool? emergencyOnly,
    String? bookingType,
  });
  Future<ProviderProfile?> getProviderById(String providerId);
  Future<void> registerProvider(ProviderProfile profile);
  Future<void> logProfileView(String providerId);
  Future<void> logDirectCall(String providerId);
}

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final HiveStorageService _storageService;
  final List<ProviderProfile> _registeredProviders = [];

  DiscoveryRepositoryImpl(this._storageService) {
    _loadCachedProviders();
  }

  void _loadCachedProviders() {
    try {
      final cachedList = _storageService.getCached(HiveBoxes.providers, 'all_providers');
      if (cachedList != null && cachedList is List) {
        for (final item in cachedList) {
          if (item is Map) {
            final profile = ProviderProfile.fromJson(Map<String, dynamic>.from(item));
            // Filter out any legacy mock data records
            if (!_isLegacyDummyProvider(profile.id)) {
              _registeredProviders.add(profile);
            }
          }
        }
      }
    } catch (e) {
      AppLogger.warning('DiscoveryRepo', 'Failed loading cached providers: $e');
    }
  }

  bool _isLegacyDummyProvider(String id) {
    return id.startsWith('prov_maid_') ||
        id.startsWith('prov_milk_') ||
        id.startsWith('prov_watch_') ||
        id.startsWith('prov_plumb_') ||
        id.startsWith('prov_elec_') ||
        id.startsWith('prov_cook_') ||
        id.startsWith('prov_driver_') ||
        id.startsWith('prov_dhobi_');
  }

  Future<void> _persistProviders() async {
    try {
      await _storageService.putCached(
        HiveBoxes.providers,
        'all_providers',
        _registeredProviders.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      AppLogger.warning('DiscoveryRepo', 'Failed caching providers: $e');
    }
  }

  @override
  Future<List<ServiceCategory>> getCategories() async {
    AppLogger.debug('DiscoveryRepo', 'Loading service categories catalog');
    return ServiceCategoriesCatalog.defaultCategories;
  }

  @override
  Future<List<SocietyDirectoryEntry>> getSocieties() async {
    AppLogger.debug('DiscoveryRepo', 'Loading societies from database');
    final Map<String, SocietyDirectoryEntry> societyMap = {};

    if (SupabaseConfig.isLiveConfigured) {
      try {
        final response = await Supabase.instance.client
            .from('societies_directory')
            .select();
        if (response.isNotEmpty) {
          for (final data in response) {
            final name = data['name']?.toString() ?? '';
            if (name.isNotEmpty) {
              societyMap[name] = SocietyDirectoryEntry(
                id: data['id']?.toString() ?? 'soc_${name.hashCode.abs()}',
                name: name,
                locality: data['locality']?.toString() ?? 'Local Area',
                city: data['city']?.toString() ?? 'City',
                pincode: data['pincode']?.toString() ?? '',
                activeWorkersCount: data['active_workers_count'] is int
                    ? data['active_workers_count'] as int
                    : int.tryParse(data['active_workers_count']?.toString() ?? '0') ?? 0,
                availableCategories: const [],
              );
            }
          }
        }
      } catch (e) {
        AppLogger.warning('DiscoveryRepo', 'Could not query Supabase societies_directory: $e');
      }
    }

    // Merge in any distinct societies actively registered by live providers
    for (final p in _registeredProviders) {
      for (final sName in p.societiesServed) {
        if (!societyMap.containsKey(sName)) {
          societyMap[sName] = SocietyDirectoryEntry(
            id: 'soc_${sName.hashCode.abs()}',
            name: sName,
            locality: p.serviceAreas.isNotEmpty ? p.serviceAreas.first : 'Local Area',
            city: 'City',
            pincode: '',
            activeWorkersCount: _registeredProviders.where((prov) => prov.societiesServed.contains(sName)).length,
            availableCategories: _registeredProviders
                .where((prov) => prov.societiesServed.contains(sName))
                .map((prov) => prov.primaryCategoryId)
                .toSet()
                .toList(),
          );
        }
      }
    }

    return societyMap.values.toList();
  }

  @override
  Future<List<ProviderProfile>> getProviders({
    String? categoryId,
    String? searchQuery,
    String? societyFilter,
    double? maxPrice,
    double? minRating,
    bool? emergencyOnly,
    String? bookingType,
  }) async {
    AppLogger.debug('DiscoveryRepo', 'Fetching live providers', {
      'category': categoryId,
      'query': searchQuery,
      'society': societyFilter,
    });

    if (SupabaseConfig.isLiveConfigured) {
      try {
        final response = await Supabase.instance.client
            .from('provider_profiles')
            .select();
        for (final item in response) {
          try {
            final p = ProviderProfile.fromJson(Map<String, dynamic>.from(item));
            if (!_isLegacyDummyProvider(p.id)) {
              final idx = _registeredProviders.indexWhere((existing) => existing.id == p.id);
              if (idx >= 0) {
                _registeredProviders[idx] = p;
              } else {
                _registeredProviders.add(p);
              }
            }
          } catch (e) {
            AppLogger.warning('DiscoveryRepo', 'Failed parsing Supabase provider: $e');
          }
        }
      } catch (e) {
        AppLogger.warning('DiscoveryRepo', 'Live Supabase provider fetch note: $e');
      }
    }

    var results = List<ProviderProfile>.from(_registeredProviders);

    // Filter by Category
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      results = results.where((p) => p.primaryCategoryId == categoryId).toList();
    }

    // Filter by Multilingual Query & Search Aliases
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      results = results.where((p) {
        final matchesName = p.businessName.toLowerCase().contains(q);
        final matchesBio = p.bio.toLowerCase().contains(q);
        final matchesArea = p.serviceAreas.any((a) => a.toLowerCase().contains(q));
        final matchesSociety = p.societiesServed.any((s) => s.toLowerCase().contains(q));

        final category = ServiceCategoriesCatalog.defaultCategories.firstWhere(
          (c) => c.id == p.primaryCategoryId,
          orElse: () => ServiceCategoriesCatalog.defaultCategories.first,
        );
        final matchesAlias = category.searchAliases.any((a) => a.toLowerCase().contains(q));

        return matchesName || matchesBio || matchesArea || matchesSociety || matchesAlias;
      }).toList();
    }

    // Filter by Society
    if (societyFilter != null && societyFilter.isNotEmpty && societyFilter != 'All Societies') {
      results = results.where((p) => p.societiesServed.contains(societyFilter)).toList();
    }

    // Filter by Emergency
    if (emergencyOnly == true) {
      results = results.where((p) => p.isEmergencyAvailable).toList();
    }

    // Filter by Price
    if (maxPrice != null && maxPrice > 0) {
      results = results.where((p) => p.basePrice <= maxPrice).toList();
    }

    // Filter by Rating
    if (minRating != null && minRating > 0) {
      results = results.where((p) => p.avgRating >= minRating).toList();
    }

    // Filter by Booking Type
    if (bookingType == 'temporary') {
      results = results.where((p) => p.isTemporaryJobModeActive).toList();
    }

    return results;
  }

  @override
  Future<ProviderProfile?> getProviderById(String providerId) async {
    final matches = _registeredProviders.where((p) => p.id == providerId);
    if (matches.isNotEmpty) return matches.first;

    if (SupabaseConfig.isLiveConfigured) {
      try {
        final response = await Supabase.instance.client
            .from('provider_profiles')
            .select()
            .eq('id', providerId)
            .maybeSingle();
        if (response != null) {
          final p = ProviderProfile.fromJson(Map<String, dynamic>.from(response));
          _registeredProviders.add(p);
          return p;
        }
      } catch (e) {
        AppLogger.warning('DiscoveryRepo', 'Supabase single provider lookup error: $e');
      }
    }

    return null;
  }

  @override
  Future<void> registerProvider(ProviderProfile profile) async {
    AppLogger.info('DiscoveryRepo', 'Registering real provider listing', {'id': profile.id});
    _registeredProviders.removeWhere((p) => p.id == profile.id);
    _registeredProviders.insert(0, profile);
    await _persistProviders();

    if (SupabaseConfig.isLiveConfigured) {
      try {
        await Supabase.instance.client
            .from('provider_profiles')
            .upsert(profile.toJson());
        AppLogger.info('DiscoveryRepo', 'Synced provider profile with live Supabase');
      } catch (e) {
        AppLogger.warning('DiscoveryRepo', 'Supabase provider upsert note: $e');
      }
    }
  }

  @override
  Future<void> logProfileView(String providerId) async {
    AppLogger.info('DiscoveryRepo', 'Profile view recorded', {'providerId': providerId});
  }

  @override
  Future<void> logDirectCall(String providerId) async {
    AppLogger.info('DiscoveryRepo', 'Direct call initiated', {'providerId': providerId});
  }
}
