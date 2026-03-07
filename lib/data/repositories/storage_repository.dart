import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/history_action.dart';
import '../models/app_settings.dart';

/// Repository for managing local storage operations
class StorageRepository {
  Box<Game>? _gamesBox;
  Box<HistoryAction>? _historyBox;
  Box<AppSettings>? _settingsBox;
  
  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlayerAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GameAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HistoryActionAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    
    // Open boxes
    _gamesBox = await Hive.openBox<Game>('games');
    _historyBox = await Hive.openBox<HistoryAction>('history');
    _settingsBox = await Hive.openBox<AppSettings>('settings');
  }
  
  // ========== Game Operations ==========
  
  Future<void> saveGame(Game game) async {
    await _gamesBox?.put(game.id, game);
  }
  
  Game? getGame(String id) {
    return _gamesBox?.get(id);
  }
  
  Future<Game?> getActiveGame() async {
    final games = _gamesBox?.values.where((g) => g.isActive).toList();
    return games?.isNotEmpty == true ? games!.first : null;
  }
  
  List<Game> getAllGames() {
    return _gamesBox?.values.toList() ?? [];
  }
  
  Future<void> deleteGame(String id) async {
    await _gamesBox?.delete(id);
  }
  
  Future<void> clearAllGames() async {
    await _gamesBox?.clear();
  }
  
  // ========== History Operations ==========
  
  Future<void> addHistoryAction(HistoryAction action) async {
    await _historyBox?.put(action.id, action);
  }
  
  List<HistoryAction> getGameHistory(String gameId) {
    return _historyBox?.values
        .where((action) => action.gameId == gameId)
        .toList()
        .reversed
        .toList() ??
        [];
  }
  
  List<HistoryAction> getAllHistory() {
    final all = _historyBox?.values.toList() ?? [];
    // Sort newest-first by timestamp so history is always chronologically correct
    // regardless of Hive insertion order or app-restart edge cases.
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }
  
  Future<void> clearHistory() async {
    await _historyBox?.clear();
  }

  Future<void> removeLastHistoryAction(String gameId) async {
    if (_historyBox == null) return;
    final entries = _historyBox!.values
        .where((a) => a.gameId == gameId)
        .toList();
    if (entries.isEmpty) return;
    // Find the most recent entry
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = entries.first;
    // Find its key and delete
    final key = _historyBox!.keys.firstWhere(
      (k) => _historyBox!.get(k)?.id == last.id,
      orElse: () => null,
    );
    if (key != null) await _historyBox!.delete(key);
  }
  
  List<HistoryAction> getFilteredHistory({
    String? gameId,
    ActionType? actionType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    var history = _historyBox?.values ?? [];
    
    if (gameId != null) {
      history = history.where((h) => h.gameId == gameId);
    }
    
    if (actionType != null) {
      history = history.where((h) => h.actionType == actionType);
    }
    
    if (fromDate != null) {
      history = history.where((h) => h.timestamp.isAfter(fromDate));
    }
    
    if (toDate != null) {
      history = history.where((h) => h.timestamp.isBefore(toDate));
    }
    
    return history.toList().reversed.toList();
  }
  
  // ========== Settings Operations ==========
  
  AppSettings getSettings() {
    return _settingsBox?.get('settings') ?? AppSettings();
  }
  
  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox?.put('settings', settings);
  }
  
  Future<void> updateDarkMode(bool isDarkMode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(isDarkMode: isDarkMode));
  }
  
  Future<void> updateDefaultTargetScore(int targetScore) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(defaultTargetScore: targetScore));
  }
  
  // ========== Cleanup ==========
  
  Future<void> close() async {
    await _gamesBox?.close();
    await _historyBox?.close();
    await _settingsBox?.close();
  }
}
