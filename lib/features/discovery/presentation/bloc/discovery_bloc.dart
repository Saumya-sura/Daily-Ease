import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../provider/domain/provider_profile.dart';
import '../../../society/domain/society_model.dart';
import '../../data/discovery_repository.dart';
import '../../domain/service_category.dart';

// Events
abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class DiscoveryLoadInitial extends DiscoveryEvent {}

class DiscoveryFilterChanged extends DiscoveryEvent {
  final String? categoryId;
  final String? searchQuery;
  final String? societyFilter;
  final double? maxPrice;
  final double? minRating;
  final bool? emergencyOnly;
  final String? bookingType;

  const DiscoveryFilterChanged({
    this.categoryId,
    this.searchQuery,
    this.societyFilter,
    this.maxPrice,
    this.minRating,
    this.emergencyOnly,
    this.bookingType,
  });

  @override
  List<Object?> get props => [
        categoryId,
        searchQuery,
        societyFilter,
        maxPrice,
        minRating,
        emergencyOnly,
        bookingType,
      ];
}

class DiscoveryToggleCompareProvider extends DiscoveryEvent {
  final ProviderProfile provider;
  const DiscoveryToggleCompareProvider(this.provider);
  @override
  List<Object?> get props => [provider];
}

class DiscoveryClearCompare extends DiscoveryEvent {}

// States
abstract class DiscoveryState extends Equatable {
  const DiscoveryState();
  @override
  List<Object?> get props => [];
}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<ServiceCategory> categories;
  final List<ProviderProfile> providers;
  final List<SocietyDirectoryEntry> societies;
  final String? selectedCategory;
  final String? searchQuery;
  final String? selectedSociety;
  final bool emergencyOnly;
  final List<ProviderProfile> compareList;

  const DiscoveryLoaded({
    required this.categories,
    required this.providers,
    required this.societies,
    this.selectedCategory,
    this.searchQuery,
    this.selectedSociety,
    this.emergencyOnly = false,
    this.compareList = const [],
  });

  DiscoveryLoaded copyWith({
    List<ServiceCategory>? categories,
    List<ProviderProfile>? providers,
    List<SocietyDirectoryEntry>? societies,
    String? selectedCategory,
    String? searchQuery,
    String? selectedSociety,
    bool? emergencyOnly,
    List<ProviderProfile>? compareList,
  }) {
    return DiscoveryLoaded(
      categories: categories ?? this.categories,
      providers: providers ?? this.providers,
      societies: societies ?? this.societies,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSociety: selectedSociety ?? this.selectedSociety,
      emergencyOnly: emergencyOnly ?? this.emergencyOnly,
      compareList: compareList ?? this.compareList,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        providers,
        societies,
        selectedCategory,
        searchQuery,
        selectedSociety,
        emergencyOnly,
        compareList,
      ];
}

class DiscoveryError extends DiscoveryState {
  final String message;
  const DiscoveryError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository _discoveryRepository;

  DiscoveryBloc(this._discoveryRepository) : super(DiscoveryLoading()) {
    on<DiscoveryLoadInitial>(_onLoadInitial);
    on<DiscoveryFilterChanged>(_onFilterChanged);
    on<DiscoveryToggleCompareProvider>(_onToggleCompare);
    on<DiscoveryClearCompare>(_onClearCompare);
  }

  Future<void> _onLoadInitial(DiscoveryLoadInitial event, Emitter<DiscoveryState> emit) async {
    emit(DiscoveryLoading());
    try {
      final categories = await _discoveryRepository.getCategories();
      final societies = await _discoveryRepository.getSocieties();
      final providers = await _discoveryRepository.getProviders();

      emit(DiscoveryLoaded(
        categories: categories,
        providers: providers,
        societies: societies,
      ));
    } catch (e, st) {
      AppLogger.error('DiscoveryBloc', 'Failed to load discovery data', error: e, stackTrace: st);
      emit(DiscoveryError(e.toString()));
    }
  }

  Future<void> _onFilterChanged(DiscoveryFilterChanged event, Emitter<DiscoveryState> emit) async {
    final currentState = state;
    if (currentState is! DiscoveryLoaded) return;

    emit(DiscoveryLoading());
    try {
      final filteredProviders = await _discoveryRepository.getProviders(
        categoryId: event.categoryId ?? currentState.selectedCategory,
        searchQuery: event.searchQuery ?? currentState.searchQuery,
        societyFilter: event.societyFilter ?? currentState.selectedSociety,
        maxPrice: event.maxPrice,
        minRating: event.minRating,
        emergencyOnly: event.emergencyOnly ?? currentState.emergencyOnly,
        bookingType: event.bookingType,
      );

      emit(currentState.copyWith(
        providers: filteredProviders,
        selectedCategory: event.categoryId ?? currentState.selectedCategory,
        searchQuery: event.searchQuery ?? currentState.searchQuery,
        selectedSociety: event.societyFilter ?? currentState.selectedSociety,
        emergencyOnly: event.emergencyOnly ?? currentState.emergencyOnly,
      ));
    } catch (e) {
      emit(DiscoveryError(e.toString()));
    }
  }

  void _onToggleCompare(DiscoveryToggleCompareProvider event, Emitter<DiscoveryState> emit) {
    final currentState = state;
    if (currentState is! DiscoveryLoaded) return;

    final currentCompare = List<ProviderProfile>.from(currentState.compareList);
    if (currentCompare.any((p) => p.id == event.provider.id)) {
      currentCompare.removeWhere((p) => p.id == event.provider.id);
    } else {
      if (currentCompare.length < 3) {
        currentCompare.add(event.provider);
      }
    }

    emit(currentState.copyWith(compareList: currentCompare));
  }

  void _onClearCompare(DiscoveryClearCompare event, Emitter<DiscoveryState> emit) {
    final currentState = state;
    if (currentState is! DiscoveryLoaded) return;
    emit(currentState.copyWith(compareList: []));
  }
}
