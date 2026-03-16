import 'package:hive/hive.dart';

part 'saved_player.g.dart';

@HiveType(typeId: 5)
class SavedPlayer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorIndex;

  @HiveField(3)
  int usageCount;

  @HiveField(4)
  DateTime lastUsed;

  SavedPlayer({
    required this.id,
    required this.name,
    required this.colorIndex,
    this.usageCount = 0,
    DateTime? lastUsed,
  }) : lastUsed = lastUsed ?? DateTime.now();
}
