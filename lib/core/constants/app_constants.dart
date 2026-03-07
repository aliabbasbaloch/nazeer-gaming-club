/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Nazeer Gaming Club';
  static const String appVersion = '1.0.0';
  
  // Snooker Ball Points
  static const int yellowPoints = 2;
  static const int greenPoints = 3;
  static const int brownPoints = 4;
  static const int bluePoints = 5;
  static const int pinkPoints = 6;
  static const int blackPoints = 7;
  static const int redPoints = 10;
  
  // Target Scores
  static const List<int> targetScores = [100, 150, 200, 250];
  static const int defaultTargetScore = 100;
  
  // Player Limits
  static const int maxPlayers = 12;
  static const int minPlayers = 1;
  
  // Warning Threshold
  static const double warningThreshold = 0.20; // 20% of target
  
  // Storage Keys
  static const String storageBoxName = 'snooker_data';
  static const String settingsKey = 'app_settings';
  static const String gamesKey = 'games';
  static const String historyKey = 'history';
}
