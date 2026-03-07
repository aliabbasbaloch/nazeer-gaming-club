import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/history_action.dart';
import '../../data/repositories/storage_repository.dart';
import 'settings_provider.dart';

/// History provider  loads from Hive on creation and exposes a [reload]
/// method that GameNotifier calls after every history write.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryAction>>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return HistoryNotifier(repository);
});

class HistoryNotifier extends StateNotifier<List<HistoryAction>> {
  final StorageRepository _repository;

  HistoryNotifier(this._repository) : super([]) {
    reload();
  }

  /// Re-read the full history from Hive. Called by GameNotifier after every
  /// _addHistoryAction() so the screen updates in the same microtask.
  void reload() {
    state = _repository.getAllHistory();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = [];
  }
}
