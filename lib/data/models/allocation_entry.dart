import 'package:hive/hive.dart';

part 'allocation_entry.g.dart';

@HiveType(typeId: 4)
class AllocationEntry {
  @HiveField(0)
  final String courseId;

  @HiveField(1)
  final String courseName;

  @HiveField(2)
  final double amountApplied;

  const AllocationEntry({
    required this.courseId,
    required this.courseName,
    required this.amountApplied,
  });
}
