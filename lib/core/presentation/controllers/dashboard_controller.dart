// presentation/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/program_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final ProgramRepository _programRepository = ProgramRepository();
  final EnrollmentRepository _enrollmentRepository = EnrollmentRepository();
  final CourseRepository _courseRepository = CourseRepository();

  var isLoading = true.obs;
  var totalCollected = 0.0.obs;
  var totalPending = 0.0.obs;
  var recentPayments = <Payment>[].obs;
  var membersWithPendingBalance = <Member>[].obs;
  var totalPrograms = 0.obs;
  var totalMembers = 0.obs;

  @override
  void onReady() {
    loadDashboardData();
    super.onReady();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;

    final payments = await _paymentRepository.getAllPayments();
    final members = await _memberRepository.getAllMembers();
    final programs = await _programRepository.getAllPrograms();
    final enrollments = await _enrollmentRepository.getAllEnrollments();
    final courses = await _courseRepository.getAllCourses();
    final courseMap = {for (final c in courses) c.id: c};

    // Calculate totals
    totalCollected.value =
        payments.fold(0.0, (sum, payment) => sum + payment.amount);

    double pending = 0.0;
    for (final member in members) {
      final ms = enrollments.where((e) => e.memberId == member.id).toList();
      double memberDebt = 0.0;
      for (final e in ms) {
        final course = courseMap[e.courseId];
        if (course != null) {
          final remaining = course.fee - e.amountPaid;
          if (remaining > 0) memberDebt += remaining;
        }
      }
      final memberPending = (memberDebt - member.accountBalance);
      pending += memberPending > 0 ? memberPending : 0.0;
    }
    totalPending.value = pending;

    // Get recent payments (last 5)
    recentPayments.value = await _paymentRepository.getRecentPayments(limit: 5);

    // Get members with pending balance
    membersWithPendingBalance.value =
        members.where((m) => m.hasPendingBalance).toList();

    // Get totals
    totalPrograms.value = programs.length;
    totalMembers.value = members.length;

    isLoading.value = false;
  }

  Future<Member?> getMemberById(String memberId) async {
    return await _memberRepository.getMemberById(memberId);
  }

  void refreshData() {
    loadDashboardData();
  }

  String formatCurrency(double amount) {
    final locale = Get.locale?.toLanguageTag() ?? 'en_US';
    final formatter = NumberFormat.currency(locale: locale, symbol: '₣', decimalDigits: 0);
    return formatter.format(amount);
  }
}
