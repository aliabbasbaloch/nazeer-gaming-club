import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/storage_repository.dart';

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageRepository _repository;
  
  SettingsNotifier(this._repository) : super(AppSettings()) {
    loadSettings();
  }
  
  /// Load settings from storage
  Future<void> loadSettings() async {
    final settings = _repository.getSettings();
    state = settings;
  }
  
  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newSettings = state.copyWith(isDarkMode: !state.isDarkMode);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }
  
  /// Update default target score
  Future<void> updateDefaultTargetScore(int score) async {
    final newSettings = state.copyWith(defaultTargetScore: score);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }
}

/// Provider for storage repository
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

/// Provider for derived AppColors — updates automatically when dark mode changes.
final appColorsProvider = Provider<AppColors>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppColors(isDark: settings.isDarkMode);
});
