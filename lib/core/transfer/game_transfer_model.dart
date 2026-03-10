class TransferPlayer {
  final String name;
  final int score;
  final bool isCompleted;
  final int turnCount;
  final int? personalTarget;

  const TransferPlayer({
    required this.name,
    required this.score,
    required this.isCompleted,
    required this.turnCount,
    this.personalTarget,
  });

  factory TransferPlayer.fromJson(Map<String, dynamic> json) {
    return TransferPlayer(
      name: json['name'] as String,
      score: json['score'] as int,
      isCompleted: json['isCompleted'] as bool,
      turnCount: json['turnCount'] as int,
      personalTarget: json['personalTarget'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'isCompleted': isCompleted,
        'turnCount': turnCount,
        if (personalTarget != null) 'personalTarget': personalTarget,
      };
}

class GameTransferModel {
  final int version;
  final String appId;
  final DateTime transferredAt;
  final int targetScore;
  final bool isSubtractMode;
  final String? currentPlayerName;
  final List<TransferPlayer> players;

  const GameTransferModel({
    required this.version,
    required this.appId,
    required this.transferredAt,
    required this.targetScore,
    required this.isSubtractMode,
    this.currentPlayerName,
    required this.players,
  });

  factory GameTransferModel.fromJson(Map<String, dynamic> json) {
    return GameTransferModel(
      version: json['v'] as int,
      appId: json['appId'] as String,
      transferredAt: DateTime.parse(json['transferredAt'] as String),
      targetScore: (json['game'] as Map<String, dynamic>)['targetScore'] as int,
      isSubtractMode:
          (json['game'] as Map<String, dynamic>)['isSubtractMode'] as bool,
      currentPlayerName:
          (json['game'] as Map<String, dynamic>)['currentPlayerName'] as String?,
      players: ((json['game'] as Map<String, dynamic>)['players'] as List)
          .map((p) => TransferPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'v': version,
        'appId': appId,
        'transferredAt': transferredAt.toUtc().toIso8601String(),
        'game': {
          'targetScore': targetScore,
          'isSubtractMode': isSubtractMode,
          'currentPlayerName': currentPlayerName,
          'players': players.map((p) => p.toJson()).toList(),
        },
      };
}

class InvalidQRException implements Exception {
  final String message;
  const InvalidQRException(this.message);

  @override
  String toString() => 'InvalidQRException: $message';
}
