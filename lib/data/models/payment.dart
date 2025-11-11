import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'payment.g.dart';

@HiveType(typeId: 3)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String memberId;

  @HiveField(2)
  final String? courseId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  final String programId;

  Payment({
    String? id,
    required this.memberId,
    this.courseId,
    required this.amount,
    DateTime? date,
    this.description,
    required this.programId,
  })  : id = id ?? const Uuid().v1(),
        date = date ?? DateTime.now(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
