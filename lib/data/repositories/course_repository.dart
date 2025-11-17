// data/repositories/course_repository.dart
import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/data/models/course.dart';

class CourseRepository {
  Future<List<Course>> getAllCourses() async {
    return HiveService.courses.values.toList();
  }

  Future<List<Course>> getCoursesByProgram(String programId) async {
    return HiveService.courses.values
        .where((course) => course.programId == programId)
        .toList();
  }

  Future<Course?> getCourseById(String id) async {
    return HiveService.courses.get(id);
  }

  Future<void> addCourse(Course course) async {
    await HiveService.courses.put(course.id, course);
  }

  Future<void> updateCourse(Course course) async {
    await HiveService.courses.put(course.id, course);
  }

  Future<void> deleteCourse(String courseId) async {
    // Delete enrollments linked to this course
    final enrollments = HiveService.enrollments.values
        .where((enrollment) => enrollment.courseId == courseId)
        .toList();
    for (final enrollment in enrollments) {
      await HiveService.enrollments.delete(enrollment.id);
    }
    await HiveService.courses.delete(courseId);
  }

  Future<void> assignMemberToCourse(String courseId, String memberId) async {
    final course = await getCourseById(courseId);
    if (course != null) {
      // Add member to course - this would need to be implemented based on your data structure
    }
  }

  Future<void> removeMemberFromCourse(String courseId, String memberId) async {
    final course = await getCourseById(courseId);
    if (course != null) {
      // Remove member from course - this would need to be implemented based on your data structure
    }
  }
}
