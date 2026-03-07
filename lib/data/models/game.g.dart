// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 1;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      id: fields[0] as String,
      players: (fields[1] as List).cast<Player>(),
      currentPlayerId: fields[2] as String?,
      targetScore: fields[3] as int,
      isSubtractMode: fields[4] as bool,
      createdAt: fields[5] as DateTime?,
      completedAt: fields[6] as DateTime?,
      isActive: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.players)
      ..writeByte(2)
      ..write(obj.currentPlayerId)
      ..writeByte(3)
      ..write(obj.targetScore)
      ..writeByte(4)
      ..write(obj.isSubtractMode)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
