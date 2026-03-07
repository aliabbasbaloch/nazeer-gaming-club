import 'package:hive/hive.dart';

part 'history_action.g.dart';

@HiveType(typeId: 2)
enum ActionType {
  @HiveField(0)
  score,
  
  @HiveField(1)
  subtract,
  
  @HiveField(2)
  playerAdded,
  
  @HiveField(3)
  playerRemoved,
  
  @HiveField(4)
  playerCompleted,
  
  @HiveField(5)
  gameReset,
  
  @HiveField(6)
  turnChanged,
}

@HiveType(typeId: 3)
class HistoryAction extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String gameId;
  
  @HiveField(2)
  final ActionType actionType;
  
  @HiveField(3)
  final String? playerId;
  
  @HiveField(4)
  final String? playerName;
  
  @HiveField(5)
  final int? pointsChanged;
  
  @HiveField(6)
  final String? ballColor;
  
  @HiveField(7)
  final String? details;
  
  @HiveField(8)
  final DateTime timestamp;
  
  HistoryAction({
    required this.id,
    required this.gameId,
    required this.actionType,
    this.playerId,
    this.playerName,
    this.pointsChanged,
    this.ballColor,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  String get actionDescription {
    switch (actionType) {
      case ActionType.score:
        return '$playerName scored $pointsChanged points ($ballColor)';
      case ActionType.subtract:
        return '$playerName lost $pointsChanged points ($ballColor)';
      case ActionType.playerAdded:
        return '$playerName joined the game';
      case ActionType.playerRemoved:
        return '$playerName left the game';
      case ActionType.playerCompleted:
        return '$playerName completed their target!';
      case ActionType.gameReset:
        return 'New game started';
      case ActionType.turnChanged:
        return 'Turn changed to $playerName';
    }
  }
}
