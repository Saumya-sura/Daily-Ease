import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/hive_storage_service.dart';
import '../../core/utils/app_logger.dart';

class LocaleCubit extends Cubit<Locale> {
  final HiveStorageService _storageService;

  LocaleCubit(this._storageService)
      : super(Locale(_storageService.getSelectedLocale()));

  Future<void> changeLocale(String languageCode) async {
    AppLogger.info('LocaleCubit', 'Changing app language', {'locale': languageCode});
    await _storageService.setSelectedLocale(languageCode);
    emit(Locale(languageCode));
  }
}
