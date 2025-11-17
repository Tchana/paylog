// data/repositories/member_repository.dart
import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/data/models/member.dart';

class MemberRepository {
  Future<List<Member>> getAllMembers() async {
    return HiveService.members.values.toList();
  }

  Future<List<Member>> getMembersByProgram(String programId) async {
    return HiveService.members.values
        .where((member) => member.programId == programId)
        .toList();
  }

  Future<Member?> getMemberById(String id) async {
    return HiveService.members.get(id);
  }

  Future<void> addMember(Member member) async {
    await HiveService.members.put(member.id, member);
  }

  Future<void> updateMember(Member member) async {
    await HiveService.members.put(member.id, member);
  }

  Future<void> deleteMember(String memberId) async {
    // Also delete associated payments
    final payments = HiveService.payments.values
        .where((payment) => payment.memberId == memberId)
        .toList();

    for (final payment in payments) {
      await HiveService.payments.delete(payment.id);
    }

    final enrollments = HiveService.enrollments.values
        .where((enrollment) => enrollment.memberId == memberId)
        .toList();

    for (final enrollment in enrollments) {
      await HiveService.enrollments.delete(enrollment.id);
    }

    await HiveService.members.delete(memberId);
  }

  Future<List<Member>> searchMembers(String query) async {
    final allMembers = await getAllMembers();
    return allMembers
        .where((member) =>
            member.name.toLowerCase().contains(query.toLowerCase()) ||
            (member.contactInfo?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();
  }
}
