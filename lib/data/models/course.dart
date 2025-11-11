import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'course.g.dart';

@HiveType(typeId: 1)
class Course extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String programId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double fee;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Course({
    String? id,
    required this.programId,
    required this.name,
    required this.fee,
    this.description,
  })  : id = id ?? const Uuid().v1(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
