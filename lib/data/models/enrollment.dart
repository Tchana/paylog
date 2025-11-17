import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'enrollment.g.dart';

@HiveType(typeId: 5)
class Enrollment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String programId;

  @HiveField(2)
  final String courseId;

  @HiveField(3)
  final String memberId;

  @HiveField(4)
  double amountPaid;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Enrollment({
    String? id,
    required this.programId,
    required this.courseId,
    required this.memberId,
    this.amountPaid = 0.0,
  })  : id = id ?? const Uuid().v1(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
