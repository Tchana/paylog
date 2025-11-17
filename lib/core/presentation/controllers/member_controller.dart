import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';

class MemberController extends GetxController {
  final MemberRepository _memberRepository = MemberRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  var members = <Member>[].obs;
  var memberPayments = <Payment>[].obs;
  var isLoading = false.obs;
  var selectedMember = Member(
    programId: '',
    name: '',
    accountBalance: 0.0,
    totalDebt: 0.0,
  ).obs;

  // Removed unnecessary override

  Future<void> fetchMembersByProgramId(String programId) async {
    try {
      isLoading.value = true;
      final memberList = await _memberRepository.getMembersByProgram(programId);
      members.value = memberList;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMemberPayments(String memberId) async {
    try {
      isLoading.value = true;
      final paymentList =
          await _paymentRepository.getPaymentsByMember(memberId);
      memberPayments.value = paymentList;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMember(Member member) async {
    await _memberRepository.addMember(member);
    // Always refresh the member list after adding a new member
    fetchMembersByProgramId(member.programId);
  }

  Future<void> updateMember(Member member) async {
    await _memberRepository.updateMember(member);
    if (members.isNotEmpty) {
      fetchMembersByProgramId(members.first.programId);
    }
  }

  Future<void> deleteMember(String memberId) async {
    await _memberRepository.deleteMember(memberId);
    if (members.isNotEmpty) {
      fetchMembersByProgramId(members.first.programId);
    }
  }

  Future<void> recordPayment(Member member, Payment payment) async {
    // Add the payment
    await _paymentRepository.addPayment(payment);

    // Refresh data
    fetchMemberPayments(member.id);
    if (members.isNotEmpty) {
      fetchMembersByProgramId(members.first.programId);
    }
  }

  String formatCurrency(double amount) {
    final locale = Get.locale?.toLanguageTag() ?? 'en_US';
    final formatter = NumberFormat.currency(locale: locale, symbol: '₣', decimalDigits: 0);
    return formatter.format(amount);
  }
}
