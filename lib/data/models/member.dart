import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'member.g.dart';

@HiveType(typeId: 2)
class Member extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String programId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? contactInfo;

  @HiveField(4)
  double accountBalance; // Unused credit

  @HiveField(5)
  double totalDebt; // Total amount owed across all courses

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  // Computed fields - not stored in Hive but calculated
  double get pendingBalance => totalDebt - accountBalance;
  bool get hasPendingBalance => pendingBalance > 0;
  bool get hasCredit => accountBalance > totalDebt;

  Member({
    String? id,
    required this.programId,
    required this.name,
    this.contactInfo,
    this.accountBalance = 0.0,
    this.totalDebt = 0.0,
  })  : id = id ?? const Uuid().v1(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
