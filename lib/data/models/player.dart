import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int score;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  int turnCount;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  int? personalTarget;

  @HiveField(7)
  int colorIndex;
  
  Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.isCompleted = false,
    this.turnCount = 0,
    this.personalTarget,
    this.colorIndex = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int effectiveTarget(int globalTarget) {
    return personalTarget ?? globalTarget;
  }
  
  Player copyWith({
    String? id,
    String? name,
    int? score,
    bool? isCompleted,
    int? turnCount,
    DateTime? createdAt,
    int? personalTarget,
    bool clearPersonalTarget = false,
    int? colorIndex,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      turnCount: turnCount ?? this.turnCount,
      createdAt: createdAt ?? this.createdAt,
      personalTarget: clearPersonalTarget ? null : (personalTarget ?? this.personalTarget),
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
  
  @override
  String toString() {
    return 'Player(id: $id, name: $name, score: $score, isCompleted: $isCompleted)';
  }
}
