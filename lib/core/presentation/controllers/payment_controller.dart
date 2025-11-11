// presentation/controllers/payment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repository = Get.find();
  final MemberRepository _memberRepository = Get.find();
  final CourseRepository _courseRepository = Get.find();

  var payments = <Payment>[].obs;
  var isLoading = false.obs;
  var members = <Member>[].obs;
  var courses = <Course>[].obs;

  @override
  void onReady() {
    loadInitialData();
    super.onReady();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    payments.value = await _repository.getAllPayments();
    members.value = await _memberRepository.getAllMembers();
    courses.value = await _courseRepository.getAllCourses();
    isLoading.value = false;
  }

  Future<void> recordPayment({
    required String memberId,
    required double amount,
    required DateTime date,
    String? courseId,
    String? description,
    required String programId,
  }) async {
    try {
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        courseId: courseId,
        amount: amount,
        date: date,
        description: description,
        programId: programId,
      );

      await _repository.addPayment(payment);
      payments.add(payment);

      // Update member's financial information
      final member = await _memberRepository.getMemberById(memberId);
      if (member != null) {
        // Create a copy of the member to modify
        final updatedMember = Member(
          id: member.id,
          programId: member.programId,
          name: member.name,
          contactInfo: member.contactInfo,
          accountBalance: member.accountBalance,
          totalDebt: member.totalDebt,
        );

        if (courseId == null) {
          // General payment - add to account balance (credit)
          updatedMember.accountBalance += amount;
        } else {
          // Course-specific payment
          // First, try to use existing credit
          if (updatedMember.accountBalance > 0) {
            final creditToUse = updatedMember.accountBalance >= amount
                ? amount
                : updatedMember.accountBalance;
            updatedMember.accountBalance -= creditToUse;
            amount -= creditToUse;

            if (creditToUse > 0) {
              Get.snackbar(
                'Credit Applied',
                'credit_applied'.trParams(
                    {'name': member.name, 'amount': creditToUse.toString()}),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.withOpacity(0.8),
                colorText: Colors.white,
              );
            }
          }

          // If there's still amount to pay, it should reduce debt
          // For simplicity, we'll reduce the total debt
          if (amount > 0) {
            updatedMember.totalDebt = updatedMember.totalDebt > amount
                ? updatedMember.totalDebt - amount
                : 0;
          }
        }

        // Update the member in repository
        updatedMember.updateTimestamp();
        await _memberRepository.updateMember(updatedMember);
      }

      // Refresh member data in MemberController
      final memberController = Get.find<MemberController>();
      await memberController.fetchMemberPayments(memberId);
      if (memberController.members.isNotEmpty) {
        await memberController
            .fetchMembersByProgramId(memberController.members.first.programId);
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Payment recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<List<Payment>> getPaymentsByMember(String memberId) async {
    return await _repository.getPaymentsByMember(memberId);
  }

  Future<List<Payment>> getPaymentsByCourse(String courseId) async {
    return await _repository.getPaymentsByCourse(courseId);
  }
}
