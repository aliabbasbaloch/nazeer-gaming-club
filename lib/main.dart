import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/storage_repository.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage
  final storageRepository = StorageRepository();
  await storageRepository.init();
  
  runApp(
    ProviderScope(
      overrides: [
        storageRepositoryProvider.overrideWithValue(storageRepository),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nazeer Gaming Club',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
