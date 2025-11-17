import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/data/models/enrollment.dart';

class EnrollmentRepository {
  Future<List<Enrollment>> getAllEnrollments() async {
    return HiveService.enrollments.values.toList();
  }
  Future<List<Enrollment>> getEnrollmentsByProgram(String programId) async {
    return HiveService.enrollments.values
        .where((e) => e.programId == programId)
        .toList();
  }

  Future<List<Enrollment>> getEnrollmentsByMember(String memberId) async {
    return HiveService.enrollments.values
        .where((e) => e.memberId == memberId)
        .toList();
  }

  Future<List<Enrollment>> getEnrollmentsByCourse(String courseId) async {
    return HiveService.enrollments.values
        .where((e) => e.courseId == courseId)
        .toList();
  }

  Future<void> addEnrollment(Enrollment enrollment) async {
    await HiveService.enrollments.put(enrollment.id, enrollment);
  }

  Future<void> updateEnrollment(Enrollment enrollment) async {
    enrollment.updateTimestamp();
    await HiveService.enrollments.put(enrollment.id, enrollment);
  }

  Future<void> deleteEnrollment(String id) async {
    await HiveService.enrollments.delete(id);
  }
}
