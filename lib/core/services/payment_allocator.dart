import 'package:get/get.dart';
import 'package:paylog/data/models/allocation_entry.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';

class PaymentAllocator {
  late final PaymentRepository _paymentRepository;
  late final MemberRepository _memberRepository;
  late final CourseRepository _courseRepository;
  late final EnrollmentRepository _enrollmentRepository;

  PaymentAllocator() {
    _paymentRepository = Get.find<PaymentRepository>();
    _memberRepository = Get.find<MemberRepository>();
    _courseRepository = Get.find<CourseRepository>();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
  }

  Future<Payment> allocateAndRecordPayment({
    required String memberId,
    required String programId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    var remaining = amount;
    final allocations = <AllocationEntry>[];

    final enrollments = await _enrollmentRepository.getEnrollmentsByMember(memberId);
    final memberProgramEnrollments = enrollments.where((e) => e.programId == programId).toList();

    final allCourses = await _courseRepository.getAllCourses();
    final courseMap = {for (final c in allCourses) c.id: c};

    memberProgramEnrollments.sort((a, b) {
      final ca = courseMap[a.courseId];
      final cb = courseMap[b.courseId];
      if (ca == null || cb == null) return 0;
      return ca.createdAt.compareTo(cb.createdAt);
    });

    for (final enrollment in memberProgramEnrollments) {
      if (remaining <= 0) break;
      final course = courseMap[enrollment.courseId];
      if (course == null) continue;
      final remainingFee = course.fee - enrollment.amountPaid;
      if (remainingFee <= 0) continue;
      final applied = remaining >= remainingFee ? remainingFee : remaining;
      if (applied <= 0) continue;
      enrollment.amountPaid += applied;
      await _enrollmentRepository.updateEnrollment(enrollment);
      allocations.add(AllocationEntry(
        courseId: enrollment.courseId,
        courseName: course.name,
        amountApplied: applied,
      ));
      remaining -= applied;
    }

    final member = await _memberRepository.getMemberById(memberId);
    if (member != null && remaining > 0) {
      member.accountBalance += remaining;
    }

    if (member != null) {
      double totalDebt = 0.0;
      for (final enrollment in memberProgramEnrollments) {
        final course = courseMap[enrollment.courseId];
        if (course != null) {
          final rem = course.fee - enrollment.amountPaid;
          if (rem > 0) totalDebt += rem;
        }
      }
      member.totalDebt = totalDebt;
      member.updateTimestamp();
      await _memberRepository.updateMember(member);
    }

    final payment = Payment(
      memberId: memberId,
      amount: amount,
      date: date,
      description: description,
      programId: programId,
      autoAssignedCourses: allocations,
    );
    await _paymentRepository.addPayment(payment);
    return payment;
  }
}
