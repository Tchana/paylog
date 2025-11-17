import 'package:get/get.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/enrollment.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';

class CourseController extends GetxController {
  late final CourseRepository _courseRepository;
  late final MemberRepository _memberRepository;
  late final EnrollmentRepository _enrollmentRepository;

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
    _courseRepository = Get.find<CourseRepository>();
    _memberRepository = Get.find<MemberRepository>();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
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
    try {
      isLoading.value = true;
      final enrollments =
          await _enrollmentRepository.getEnrollmentsByCourse(courseId);
      final memberIds = enrollments.map((e) => e.memberId).toSet();

      // Fetch members
      final members = <Member>[];
      for (var memberId in memberIds) {
        final member = await _memberRepository.getMemberById(memberId);
        if (member != null) {
          members.add(member);
        }
      }

      courseMembers.value = members;
    } finally {
      isLoading.value = false;
    }
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

  Future<void> assignMembersToCourse(
      Course course, List<Member> members) async {
    try {
      isLoading.value = true;
      for (final member in members) {
        final existing = await _enrollmentRepository.getEnrollmentsByMember(member.id);
        final already = existing.any((e) => e.courseId == course.id);
        if (!already) {
          final enrollment = Enrollment(
            programId: course.programId,
            courseId: course.id,
            memberId: member.id,
          );
          await _enrollmentRepository.addEnrollment(enrollment);
          if (member.accountBalance > 0) {
            final remainingFee = course.fee - enrollment.amountPaid;
            final applied = member.accountBalance >= remainingFee
                ? remainingFee
                : member.accountBalance;
            if (applied > 0) {
              enrollment.amountPaid += applied;
              member.accountBalance -= applied;
              await _enrollmentRepository.updateEnrollment(enrollment);
              await _memberRepository.updateMember(member);
            }
          }
          final memberEnrollments =
              await _enrollmentRepository.getEnrollmentsByMember(member.id);
          double debt = 0.0;
          for (final e in memberEnrollments) {
            if (e.programId == course.programId) {
              final c = await _courseRepository.getCourseById(e.courseId);
              if (c != null) {
                final rem = c.fee - e.amountPaid;
                if (rem > 0) debt += rem;
              }
            }
          }
          member.totalDebt = debt;
          await _memberRepository.updateMember(member);
        }
      }

      // Refresh the course members list
      await fetchCourseMembers(course.id);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMemberFromCourse(String memberId, String courseId) async {
    // Implementation would depend on how the relationship is stored
  }
}
