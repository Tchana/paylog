import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'program.g.dart';

@HiveType(typeId: 0)
class Program extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  Program({
    String? id,
    required this.name,
    this.description,
  })  : id = id ?? const Uuid().v1(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
