import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;
  
  @HiveField(1)
  int defaultTargetScore;
  
  @HiveField(2)
  DateTime lastModified;

  @HiveField(3)
  bool turnTimerEnabled;

  @HiveField(4)
  bool keepScreenOn;

  @HiveField(5)
  bool hapticEnabled;
  
  AppSettings({
    this.isDarkMode = false,
    this.defaultTargetScore = 100,
    this.turnTimerEnabled = true,
    this.keepScreenOn = true,
    this.hapticEnabled = true,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();
  
  AppSettings copyWith({
    bool? isDarkMode,
    int? defaultTargetScore,
    DateTime? lastModified,
    bool? turnTimerEnabled,
    bool? keepScreenOn,
    bool? hapticEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultTargetScore: defaultTargetScore ?? this.defaultTargetScore,
      lastModified: lastModified ?? DateTime.now(),
      turnTimerEnabled: turnTimerEnabled ?? this.turnTimerEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}
