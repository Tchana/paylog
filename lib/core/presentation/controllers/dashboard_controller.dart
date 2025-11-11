// presentation/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/program_repository.dart';

class DashboardController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final ProgramRepository _programRepository = ProgramRepository();

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

    // Calculate totals
    totalCollected.value =
        payments.fold(0.0, (sum, payment) => sum + payment.amount);

    // Calculate pending (this would need more complex logic based on course fees)
    totalPending.value =
        members.fold(0.0, (sum, member) => sum + member.pendingBalance);

    // Get recent payments (last 5)
    recentPayments.value = payments.take(5).toList();

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
    return '₣${amount.toStringAsFixed(0)}';
  }
}
