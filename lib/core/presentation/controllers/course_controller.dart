import 'package:get/get.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';

class CourseController extends GetxController {
  late final CourseRepository _courseRepository;
  late final MemberRepository _memberRepository;
  late final PaymentRepository _paymentRepository;

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
    _paymentRepository = Get.find<PaymentRepository>();
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
      // Fetch all payments for this course
      final payments = await _paymentRepository.getPaymentsByCourse(courseId);

      // Get unique member IDs from payments
      final memberIds = <String>{};
      for (var payment in payments) {
        memberIds.add(payment.memberId);
      }

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
      // For each member, create a payment record to establish the relationship
      for (var member in members) {
        // Check if member is already assigned to this course
        final existingPayments =
            await _paymentRepository.getPaymentsByCourse(course.id);
        final isAlreadyAssigned =
            existingPayments.any((payment) => payment.memberId == member.id);

        if (!isAlreadyAssigned) {
          // Create a payment with 0 amount to establish the relationship
          final payment = Payment(
            memberId: member.id,
            courseId: course.id,
            amount: 0.0,
            date: DateTime.now(),
            description: 'Course enrollment',
            programId: course.programId,
          );
          await _paymentRepository.addPayment(payment);
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
