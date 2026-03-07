// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryActionAdapter extends TypeAdapter<HistoryAction> {
  @override
  final int typeId = 3;

  @override
  HistoryAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryAction(
      id: fields[0] as String,
      gameId: fields[1] as String,
      actionType: fields[2] as ActionType,
      playerId: fields[3] as String?,
      playerName: fields[4] as String?,
      pointsChanged: fields[5] as int?,
      ballColor: fields[6] as String?,
      details: fields[7] as String?,
      timestamp: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryAction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameId)
      ..writeByte(2)
      ..write(obj.actionType)
      ..writeByte(3)
      ..write(obj.playerId)
      ..writeByte(4)
      ..write(obj.playerName)
      ..writeByte(5)
      ..write(obj.pointsChanged)
      ..writeByte(6)
      ..write(obj.ballColor)
      ..writeByte(7)
      ..write(obj.details)
      ..writeByte(8)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActionTypeAdapter extends TypeAdapter<ActionType> {
  @override
  final int typeId = 2;

  @override
  ActionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActionType.score;
      case 1:
        return ActionType.subtract;
      case 2:
        return ActionType.playerAdded;
      case 3:
        return ActionType.playerRemoved;
      case 4:
        return ActionType.playerCompleted;
      case 5:
        return ActionType.gameReset;
      case 6:
        return ActionType.turnChanged;
      default:
        return ActionType.score;
    }
  }

  @override
  void write(BinaryWriter writer, ActionType obj) {
    switch (obj) {
      case ActionType.score:
        writer.writeByte(0);
        break;
      case ActionType.subtract:
        writer.writeByte(1);
        break;
      case ActionType.playerAdded:
        writer.writeByte(2);
        break;
      case ActionType.playerRemoved:
        writer.writeByte(3);
        break;
      case ActionType.playerCompleted:
        writer.writeByte(4);
        break;
      case ActionType.gameReset:
        writer.writeByte(5);
        break;
      case ActionType.turnChanged:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
