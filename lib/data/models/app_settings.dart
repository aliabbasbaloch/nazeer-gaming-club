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
  
  AppSettings({
    this.isDarkMode = false,
    this.defaultTargetScore = 100,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();
  
  AppSettings copyWith({
    bool? isDarkMode,
    int? defaultTargetScore,
    DateTime? lastModified,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultTargetScore: defaultTargetScore ?? this.defaultTargetScore,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
}
