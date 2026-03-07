import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/game.dart';
import 'game_provider.dart';

/// Exposes elapsed game seconds (int).
/// • 0 while no score has been recorded yet.
/// • Ticks every second after the first score is added.
/// • Resets to 0 whenever a new game starts or the game is cleared.
final gameTimerProvider =
    StateNotifierProvider<GameTimerNotifier, int>((ref) {
  return GameTimerNotifier(ref);
});

class GameTimerNotifier extends StateNotifier<int> {
  final Ref _ref;
  Timer? _ticker;
  String? _trackedGameId;
  bool _timerStarted = false;

  GameTimerNotifier(this._ref) : super(0) {
    // React to every game state change.
    _ref.listen<Game?>(gameProvider, (prev, next) {
      _handleGameChange(next);
    });
    // Also pick up the current state in case the provider is created after
    // the game is already loaded (e.g. hot-restart).
    _handleGameChange(_ref.read(gameProvider));
  }

  void _handleGameChange(Game? game) {
    if (game == null) {
      _reset();
      return;
    }

    // Detect game ID change → new game was started → reset.
    if (game.id != _trackedGameId) {
      _reset();
      _trackedGameId = game.id;
    }

    // Start ticking as soon as any player has scored.
    if (!_timerStarted) {
      final anyScore = game.players.any((p) => p.score != 0);
      if (anyScore) _startTicker();
    }
  }

  void _startTicker() {
    _timerStarted = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) state = state + 1;
    });
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    _timerStarted = false;
    _trackedGameId = null;
    state = 0;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Formats elapsed seconds into "MM:SS".
String formatGameTime(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
