// data/repositories/program_repository.dart
import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/data/models/program.dart';

class ProgramRepository {
  Future<List<Program>> getAllPrograms() async {
    return HiveService.programs.values.toList();
  }

  Future<void> addProgram(Program program) async {
    await HiveService.programs.put(program.id, program);
  }

  Future<void> updateProgram(Program program) async {
    program.updatedAt = DateTime.now();
    await HiveService.programs.put(program.id, program);
  }

  Future<void> deleteProgram(String programId) async {
    // Also delete associated members, courses, and payments
    final members = HiveService.members.values
        .where((member) => member.programId == programId)
        .toList();

    for (final member in members) {
      await HiveService.members.delete(member.id);
    }

    final courses = HiveService.courses.values
        .where((course) => course.programId == programId)
        .toList();

    for (final course in courses) {
      await HiveService.courses.delete(course.id);
    }

    final payments = HiveService.payments.values
        .where((payment) => payment.programId == programId)
        .toList();

    for (final payment in payments) {
      await HiveService.payments.delete(payment.id);
    }

    final enrollments = HiveService.enrollments.values
        .where((enrollment) => enrollment.programId == programId)
        .toList();

    for (final enrollment in enrollments) {
      await HiveService.enrollments.delete(enrollment.id);
    }

    await HiveService.programs.delete(programId);
  }

  Future<Program?> getProgramById(String programId) async {
    return HiveService.programs.get(programId);
  }
}
