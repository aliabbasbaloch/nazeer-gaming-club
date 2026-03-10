import 'dart:convert';

import '../../data/models/game.dart';
import 'game_transfer_model.dart';

class GameTransferService {
  static const String _appId = 'nazeer_gaming_club';
  static const int _version = 1;

  /// Encode a [Game] into a JSON string suitable for QR code generation.
  static String encodeGame(Game game) {
    final transfer = GameTransferModel(
      version: _version,
      appId: _appId,
      transferredAt: DateTime.now(),
      targetScore: game.targetScore,
      isSubtractMode: game.isSubtractMode,
      currentPlayerName: game.currentPlayer?.name,
      players: game.players
          .map((p) => TransferPlayer(
                name: p.name,
                score: p.score,
                isCompleted: p.isCompleted,
                turnCount: p.turnCount,
                personalTarget: p.personalTarget,
              ))
          .toList(),
    );
    return jsonEncode(transfer.toJson());
  }

  /// Decode a raw QR string into a [GameTransferModel].
  /// Throws [InvalidQRException] if the data is not valid.
  static GameTransferModel decodeGame(String rawValue) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(rawValue) as Map<String, dynamic>;
    } catch (_) {
      throw const InvalidQRException('Not a valid QR code for this app');
    }

    if (json['appId'] != _appId) {
      throw const InvalidQRException('QR code is not from Nazeer Gaming Club');
    }

    if (json['v'] != _version) {
      throw const InvalidQRException('Unsupported QR version');
    }

    final gameMap = json['game'] as Map<String, dynamic>?;
    if (gameMap == null) {
      throw const InvalidQRException('Missing game data');
    }

    final players = gameMap['players'] as List?;
    if (players == null || players.isEmpty) {
      throw const InvalidQRException('No players in transferred game');
    }

    for (final p in players) {
      final name = (p as Map<String, dynamic>)['name'] as String?;
      if (name == null || name.trim().isEmpty) {
        throw const InvalidQRException('Player name cannot be empty');
      }
    }

    try {
      return GameTransferModel.fromJson(json);
    } catch (_) {
      throw const InvalidQRException('Corrupted game data in QR code');
    }
  }
}
