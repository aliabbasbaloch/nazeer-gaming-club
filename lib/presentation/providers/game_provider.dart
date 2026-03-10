import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/game.dart';
import '../../data/models/player.dart';
import '../../data/models/history_action.dart';
import '../../data/models/snooker_ball.dart';
import '../../data/repositories/storage_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/transfer/game_transfer_model.dart';
import 'settings_provider.dart';
import 'history_provider.dart';

/// Provider for current game state
final gameProvider = StateNotifierProvider<GameNotifier, Game?>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return GameNotifier(
    repository,
    // After every _addHistoryAction Hive write, reload the history list so
    // the History screen updates instantly (same microtask, no recreation).
    onHistoryChanged: () => ref.read(historyProvider.notifier).reload(),
  );
});

class GameNotifier extends StateNotifier<Game?> {
  final StorageRepository _repository;
  final _uuid = const Uuid();
  final List<Game> _undoStack = []; // multi-step undo
  final void Function()? _onHistoryChanged;

  GameNotifier(this._repository, {void Function()? onHistoryChanged})
      : _onHistoryChanged = onHistoryChanged,
        super(null) {
    loadActiveGame();
  }
  
  /// Load the active game from storage
  Future<void> loadActiveGame() async {
    final game = await _repository.getActiveGame();
    if (game != null) {
      state = game;
    }
  }
  
  /// Create a new game
  Future<void> createNewGame({int? targetScore}) async {
    // Mark current game as inactive
    if (state != null) {
      final oldGame = state!.copyWith(isActive: false);
      await _repository.saveGame(oldGame);
    }
    
    final newGame = Game(
      id: _uuid.v4(),
      players: [],
      targetScore: targetScore ?? AppConstants.defaultTargetScore,
    );
    
    await _repository.saveGame(newGame);
    await _addHistoryAction(
      gameId: newGame.id,
      actionType: ActionType.gameReset,
      details: 'New game started with target ${newGame.targetScore}',
    );
    
    state = newGame;
  }
  
  /// Add a player to the game
  Future<void> addPlayer(String playerName) async {
    if (state == null) {
      await createNewGame();
    }
    
    final currentGame = state!;
    
    if (currentGame.players.length >= AppConstants.maxPlayers) {
      throw Exception('Maximum ${AppConstants.maxPlayers} players allowed');
    }
    
    final newPlayer = Player(
      id: _uuid.v4(),
      name: playerName.trim(),
    );
    
    final updatedPlayers = [...currentGame.players, newPlayer];
    final updatedGame = currentGame.copyWith(
      players: updatedPlayers,
      currentPlayerId: currentGame.currentPlayerId ?? newPlayer.id,
    );
    
    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: ActionType.playerAdded,
      playerId: newPlayer.id,
      playerName: newPlayer.name,
    );
    
    state = updatedGame;
  }
  
  /// Remove a player from the game
  Future<void> removePlayer(String playerId) async {
    if (state == null) return;
    
    final currentGame = state!;
    final player = currentGame.players.firstWhere((p) => p.id == playerId);
    final updatedPlayers = currentGame.players.where((p) => p.id != playerId).toList();
    
    // Update current player if removed
    String? newCurrentPlayerId = currentGame.currentPlayerId;
    if (currentGame.currentPlayerId == playerId) {
      final activePlayers = updatedPlayers.where((p) => !p.isCompleted).toList();
      newCurrentPlayerId = activePlayers.isNotEmpty ? activePlayers.first.id : null;
    }
    
    final updatedGame = currentGame.copyWith(
      players: updatedPlayers,
      currentPlayerId: newCurrentPlayerId,
    );
    
    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: ActionType.playerRemoved,
      playerId: playerId,
      playerName: player.name,
    );
    
    state = updatedGame;
  }
  
  /// Set the current active player
  Future<void> setCurrentPlayer(String playerId) async {
    if (state == null) return;
    
    final currentGame = state!;
    final player = currentGame.players.firstWhere((p) => p.id == playerId);
    
    if (player.isCompleted) return;
    
    final updatedGame = currentGame.copyWith(currentPlayerId: playerId);
    
    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: ActionType.turnChanged,
      playerId: playerId,
      playerName: player.name,
    );
    
    state = updatedGame;
  }
  
  /// Move to the next active player in the original player order.
  ///
  /// We search through [Game.players] (the full list, including completed
  /// players) so that the rotation is always predictable: if the current
  /// player just finished we still advance in the same clockwise sequence
  /// rather than jumping to index-0 of the filtered activePlayers list.
  Future<void> nextPlayer() async {
    if (state == null) return;

    final currentGame = state!;
    final allPlayers = currentGame.players;

    if (allPlayers.isEmpty) return;

    // Find the current player in the full (unfiltered) list.
    final currentIndex = allPlayers.indexWhere(
      (p) => p.id == currentGame.currentPlayerId,
    );

    // Walk forward (wrapping) until we find a non-completed player.
    for (int i = 1; i <= allPlayers.length; i++) {
      final candidate = allPlayers[(currentIndex + i) % allPlayers.length];
      if (!candidate.isCompleted) {
        await setCurrentPlayer(candidate.id);
        return;
      }
    }
    // All players completed – nothing to do.
  }
  
  /// Add points to current player
  Future<void> scorePoints(SnookerBall ball) async {
    if (state == null || state!.currentPlayerId == null) return;
    
    final currentGame = state!;
    final currentPlayer = currentGame.currentPlayer!;
    
    if (currentPlayer.isCompleted) {
      await nextPlayer();
      return;
    }
    
    final pointsToAdd = currentGame.isSubtractMode ? -ball.points : ball.points;
    final newScore = (currentPlayer.score + pointsToAdd).clamp(-100, double.infinity).toInt();
    final effective = currentPlayer.effectiveTarget(currentGame.targetScore);
    final isCompleted = newScore >= effective;

    // Save snapshot for undo before mutating
    _undoStack.add(currentGame);
    if (_undoStack.length > 20) _undoStack.removeAt(0); // cap at 20 steps
    
    // Update player
    final updatedPlayer = currentPlayer.copyWith(
      score: newScore,
      isCompleted: isCompleted,
      turnCount: currentPlayer.turnCount + 1,
    );
    
    final updatedPlayers = currentGame.players.map((p) {
      return p.id == currentPlayer.id ? updatedPlayer : p;
    }).toList();
    
    final updatedGame = currentGame.copyWith(players: updatedPlayers);
    
    await _repository.saveGame(updatedGame);
    
    // Add history
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: currentGame.isSubtractMode ? ActionType.subtract : ActionType.score,
      playerId: currentPlayer.id,
      playerName: currentPlayer.name,
      pointsChanged: ball.points,
      ballColor: ball.name,
      details: '$newScore',  // running total after this action
    );
    
    if (isCompleted) {
      await _addHistoryAction(
        gameId: currentGame.id,
        actionType: ActionType.playerCompleted,
        playerId: currentPlayer.id,
        playerName: currentPlayer.name,
        details: 'Reached target of $effective',
      );
    }
    
    state = updatedGame;
    
    // Auto-switch to next player if completed
    if (isCompleted) {
      await nextPlayer();
    }
  }
  
  
  /// Undo the last score action
  Future<void> undoLastAction() async {
    if (_undoStack.isEmpty) return;
    final restored = _undoStack.removeLast();
    await _repository.saveGame(restored);
    await _repository.removeLastHistoryAction(restored.id);
    _onHistoryChanged?.call(); // refresh history after Hive delete
    state = restored;
  }

  /// Toggle subtract mode
  Future<void> toggleSubtractMode() async {
    if (state == null) return;
    
    final currentGame = state!;
    final updatedGame = currentGame.copyWith(
      isSubtractMode: !currentGame.isSubtractMode,
    );
    
    await _repository.saveGame(updatedGame);
    state = updatedGame;
  }
  
  /// Change target score
  Future<void> changeTargetScore(int newTarget) async {
    if (state == null) return;
    
    final currentGame = state!;
    final updatedGame = currentGame.copyWith(targetScore: newTarget);
    
    await _repository.saveGame(updatedGame);
    state = updatedGame;
  }
  
  /// Add a history action and immediately notify the history notifier so the
  /// screen updates in the same microtask (no full provider recreation needed).
  Future<void> _addHistoryAction({
    required String gameId,
    required ActionType actionType,
    String? playerId,
    String? playerName,
    int? pointsChanged,
    String? ballColor,
    String? details,
  }) async {
    final action = HistoryAction(
      id: _uuid.v4(),
      gameId: gameId,
      actionType: actionType,
      playerId: playerId,
      playerName: playerName,
      pointsChanged: pointsChanged,
      ballColor: ballColor,
      details: details,
    );

    await _repository.addHistoryAction(action);
    // Reload the history list immediately after the Hive write completes so
    // the UI reflects the new entry without waiting for a full rebuild cycle.
    _onHistoryChanged?.call();
  }

  /// Load a game transferred via QR code.
  Future<void> loadTransferredGame(GameTransferModel transfer) async {
    // Mark current game as inactive
    if (state != null) {
      final oldGame = state!.copyWith(isActive: false);
      await _repository.saveGame(oldGame);
    }

    // Create players with fresh UUIDs
    final players = transfer.players
        .map((tp) => Player(
              id: _uuid.v4(),
              name: tp.name,
              score: tp.score,
              isCompleted: tp.isCompleted,
              turnCount: tp.turnCount,
              personalTarget: tp.personalTarget,
            ))
        .toList();

    // Resolve currentPlayerId by matching name
    String? currentPlayerId;
    if (transfer.currentPlayerName != null) {
      final match = players.where((p) => p.name == transfer.currentPlayerName);
      if (match.isNotEmpty) currentPlayerId = match.first.id;
    }
    currentPlayerId ??=
        players.where((p) => !p.isCompleted).firstOrNull?.id;

    final newGame = Game(
      id: _uuid.v4(),
      players: players,
      currentPlayerId: currentPlayerId,
      targetScore: transfer.targetScore,
      isSubtractMode: transfer.isSubtractMode,
    );

    await _repository.saveGame(newGame);
    await _addHistoryAction(
      gameId: newGame.id,
      actionType: ActionType.gameReset,
      details:
          'Game transferred via QR — ${players.length} players loaded',
    );

    _undoStack.clear();
    state = newGame;
  }

  /// Update global target during game
  Future<void> updateGlobalTarget(int newTarget) async {
    if (state == null) return;

    _undoStack.add(state!);
    if (_undoStack.length > 20) _undoStack.removeAt(0);

    final updatedPlayers = state!.players.map((p) {
      final effective = p.effectiveTarget(newTarget);
      if (!p.isCompleted && p.score >= effective) {
        return p.copyWith(isCompleted: true);
      }
      return p;
    }).toList();

    final updatedGame = state!.copyWith(
      targetScore: newTarget,
      players: updatedPlayers,
    );

    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: updatedGame.id,
      actionType: ActionType.gameReset,
      details: 'Global target changed to $newTarget pts',
    );

    state = updatedGame;
  }

  /// Set or clear per-player personal target
  Future<void> setPlayerTarget(String playerId, int? personalTarget) async {
    if (state == null) return;

    _undoStack.add(state!);
    if (_undoStack.length > 20) _undoStack.removeAt(0);

    final updatedPlayers = state!.players.map((p) {
      if (p.id != playerId) return p;
      final updated = personalTarget != null
          ? p.copyWith(personalTarget: personalTarget)
          : p.copyWith(clearPersonalTarget: true);
      final effective = updated.effectiveTarget(state!.targetScore);
      if (!updated.isCompleted && updated.score >= effective) {
        return updated.copyWith(isCompleted: true);
      }
      return updated;
    }).toList();

    final updatedGame = state!.copyWith(players: updatedPlayers);
    await _repository.saveGame(updatedGame);

    final targetPlayer = updatedPlayers.firstWhere((p) => p.id == playerId);
    await _addHistoryAction(
      gameId: updatedGame.id,
      actionType: ActionType.gameReset,
      details: personalTarget != null
          ? 'Personal target set to $personalTarget pts for ${targetPlayer.name}'
          : 'Personal target removed for ${targetPlayer.name}',
    );

    state = updatedGame;

    // Auto-advance if the current player just completed
    if (playerId == updatedGame.currentPlayerId &&
        targetPlayer.isCompleted) {
      await nextPlayer();
    }
  }
}
