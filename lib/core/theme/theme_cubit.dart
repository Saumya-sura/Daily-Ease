import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/hive_storage_service.dart';

class ThemeCubit extends Cubit<bool> {
  final HiveStorageService _storageService;

  ThemeCubit(this._storageService) : super(_storageService.isDarkMode());

  void toggleTheme() {
    final newMode = !state;
    _storageService.setDarkMode(newMode);
    emit(newMode);
  }
}
