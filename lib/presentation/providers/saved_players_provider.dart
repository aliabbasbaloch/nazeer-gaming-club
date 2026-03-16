import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/saved_player.dart';
import '../../data/repositories/storage_repository.dart';
import 'settings_provider.dart';

final savedPlayersProvider =
    StateNotifierProvider<SavedPlayersNotifier, List<SavedPlayer>>((ref) {
  return SavedPlayersNotifier(ref.read(storageRepositoryProvider));
});

class SavedPlayersNotifier extends StateNotifier<List<SavedPlayer>> {
  final StorageRepository _storage;
  final _uuid = const Uuid();

  SavedPlayersNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.getSavedPlayers();
  }

  Future<void> savePlayer(String name, int colorIndex) async {
    final existing = state
        .where((p) => p.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    if (existing != null) {
      final updated = SavedPlayer(
        id: existing.id,
        name: existing.name,
        colorIndex: colorIndex,
        usageCount: existing.usageCount + 1,
        lastUsed: DateTime.now(),
      );
      await _storage.saveSavedPlayer(updated);
    } else {
      final player = SavedPlayer(
        id: _uuid.v4(),
        name: name,
        colorIndex: colorIndex,
        usageCount: 1,
        lastUsed: DateTime.now(),
      );
      await _storage.saveSavedPlayer(player);
    }
    _load();
  }

  Future<void> deletePlayer(String id) async {
    await _storage.deleteSavedPlayer(id);
    _load();
  }

  Future<void> clearAll() async {
    await _storage.clearSavedPlayers();
    _load();
  }
}
