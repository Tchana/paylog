import 'package:get/get.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';

class CourseController extends GetxController {
  final CourseRepository _courseRepository = CourseRepository();
  final MemberRepository _memberRepository = MemberRepository();

  var courses = <Course>[].obs;
  var courseMembers = <Member>[].obs;
  var isLoading = false.obs;
  var selectedCourse = Course(
    programId: '',
    name: '',
    fee: 0.0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchCoursesByProgramId(String programId) async {
    try {
      isLoading.value = true;
      final courseList = await _courseRepository.getCoursesByProgram(programId);
      courses.value = courseList;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCourseMembers(String courseId) async {
    // This would need to be implemented based on how members are linked to courses
    // For now, we'll fetch all members in the program
    courseMembers.value = [];
  }

  Future<void> addCourse(Course course) async {
    await _courseRepository.addCourse(course);
    // Always refresh the course list after adding a new course
    fetchCoursesByProgramId(course.programId);
  }

  Future<void> updateCourse(Course course) async {
    await _courseRepository.updateCourse(course);
    if (courses.isNotEmpty) {
      fetchCoursesByProgramId(courses.first.programId);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    await _courseRepository.deleteCourse(courseId);
    if (courses.isNotEmpty) {
      fetchCoursesByProgramId(courses.first.programId);
    }
  }

  Future<void> assignMemberToCourse(String memberId, String courseId) async {
    // Implementation would depend on how the relationship is stored
  }

  Future<void> removeMemberFromCourse(String memberId, String courseId) async {
    // Implementation would depend on how the relationship is stored
  }
}
