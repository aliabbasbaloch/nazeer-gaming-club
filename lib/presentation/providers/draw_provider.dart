import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State enum for the Name Draw screen
enum DrawState { empty, ready, drawing, complete }

/// State class for the Name Draw feature
class DrawData {
  final List<String> candidateNames;
  final List<String> drawnNames;
  final List<String> remainingPool;
  final DrawState drawState;
  final String? lastDrawnName;

  const DrawData({
    this.candidateNames = const [],
    this.drawnNames = const [],
    this.remainingPool = const [],
    this.drawState = DrawState.empty,
    this.lastDrawnName,
  });

  DrawData copyWith({
    List<String>? candidateNames,
    List<String>? drawnNames,
    List<String>? remainingPool,
    DrawState? drawState,
    String? lastDrawnName,
    bool clearLastDrawn = false,
  }) {
    return DrawData(
      candidateNames: candidateNames ?? this.candidateNames,
      drawnNames: drawnNames ?? this.drawnNames,
      remainingPool: remainingPool ?? this.remainingPool,
      drawState: drawState ?? this.drawState,
      lastDrawnName: clearLastDrawn ? null : (lastDrawnName ?? this.lastDrawnName),
    );
  }
}

/// Provider for Name Draw state
final drawProvider = StateNotifierProvider<DrawNotifier, DrawData>((ref) {
  return DrawNotifier();
});

class DrawNotifier extends StateNotifier<DrawData> {
  final _random = Random();

  DrawNotifier() : super(const DrawData());

  /// Add a name to the candidate list
  void addName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }
    if (state.candidateNames.length >= 12) {
      return;
    }
    if (state.drawState == DrawState.drawing || 
        state.drawState == DrawState.complete) {
      return;
    }

    final updatedCandidates = [...state.candidateNames, trimmedName];
    final newState = updatedCandidates.length >= 2 
        ? DrawState.ready 
        : DrawState.empty;

    state = state.copyWith(
      candidateNames: updatedCandidates,
      drawState: newState,
    );
  }

  /// Remove a name from the candidate list (only before draw starts)
  void removeName(int index) {
    if (state.drawState == DrawState.drawing || 
        state.drawState == DrawState.complete) {
      return;
    }
    if (index < 0 || index >= state.candidateNames.length) {
      return;
    }

    final updatedCandidates = [...state.candidateNames]..removeAt(index);
    final newState = updatedCandidates.length >= 2 
        ? DrawState.ready 
        : DrawState.empty;

    state = state.copyWith(
      candidateNames: updatedCandidates,
      drawState: newState,
    );
  }

  /// Draw the next name randomly from the remaining pool
  void drawNext() {
    // Need at least 2 names to start
    if (state.candidateNames.length < 2) return;

    // Initialize pool on first draw
    List<String> pool;
    if (state.drawState == DrawState.empty || state.drawState == DrawState.ready) {
      pool = List<String>.from(state.candidateNames);
    } else {
      pool = List<String>.from(state.remainingPool);
    }

    if (pool.isEmpty) return;

    // Pick random name
    final randomIndex = _random.nextInt(pool.length);
    final drawnName = pool.removeAt(randomIndex);
    final updatedDrawnNames = [...state.drawnNames, drawnName];

    // Determine new state
    final newState = pool.isEmpty ? DrawState.complete : DrawState.drawing;

    state = state.copyWith(
      drawnNames: updatedDrawnNames,
      remainingPool: pool,
      drawState: newState,
      lastDrawnName: drawnName,
    );
  }

  /// Check if we can add the drawn names to a game
  bool get canAddToGame => state.drawState == DrawState.complete;

  /// Get the drawn names in order (for passing to game)
  List<String> get drawnNamesInOrder => List<String>.from(state.drawnNames);

  /// Reset the entire draw state
  void reset() {
    state = const DrawData();
  }
}
