import 'package:hive/hive.dart';
import 'player.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  List<Player> players;
  
  @HiveField(2)
  String? currentPlayerId;
  
  @HiveField(3)
  int targetScore;
  
  @HiveField(4)
  bool isSubtractMode;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime? completedAt;
  
  @HiveField(7)
  bool isActive;
  
  Game({
    required this.id,
    required this.players,
    this.currentPlayerId,
    this.targetScore = 150,
    this.isSubtractMode = false,
    DateTime? createdAt,
    this.completedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Player? get currentPlayer {
    if (currentPlayerId == null) return null;
    try {
      return players.firstWhere((p) => p.id == currentPlayerId);
    } catch (e) {
      return null;
    }
  }
  
  List<Player> get activePlayers {
    return players.where((p) => !p.isCompleted).toList();
  }
  
  List<Player> get completedPlayers {
    return players.where((p) => p.isCompleted).toList();
  }
  
  bool get isGameComplete {
    return players.isNotEmpty && players.every((p) => p.isCompleted);
  }
  
  Game copyWith({
    String? id,
    List<Player>? players,
    String? currentPlayerId,
    int? targetScore,
    bool? isSubtractMode,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isActive,
  }) {
    return Game(
      id: id ?? this.id,
      players: players ?? this.players,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      targetScore: targetScore ?? this.targetScore,
      isSubtractMode: isSubtractMode ?? this.isSubtractMode,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
