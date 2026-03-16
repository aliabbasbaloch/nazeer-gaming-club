// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedPlayerAdapter extends TypeAdapter<SavedPlayer> {
  @override
  final int typeId = 5;

  @override
  SavedPlayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedPlayer(
      id: fields[0] as String,
      name: fields[1] as String,
      colorIndex: fields[2] as int,
      usageCount: fields[3] == null ? 0 : fields[3] as int,
      lastUsed: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedPlayer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorIndex)
      ..writeByte(3)
      ..write(obj.usageCount)
      ..writeByte(4)
      ..write(obj.lastUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
