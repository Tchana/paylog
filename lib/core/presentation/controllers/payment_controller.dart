// presentation/controllers/payment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';

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

    // Update member's account balance
    final member = members.firstWhere((m) => m.id == memberId);
    if (courseId == null) {
      // General payment - add to account balance
      member.accountBalance += amount;
      await _memberRepository.updateMember(member);
    } else {
      // Course-specific payment logic
      await _applyPaymentToCourse(member, amount, courseId);
    }

    // Show success message with member name
    final memberName = member.name;
    Get.snackbar(
      'success'.tr,
      'payment_recorded'.trParams({'name': memberName, 'amount': amount.toString()}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  Future<void> _applyPaymentToCourse(Member member, double amount, String courseId) async {
    final course = courses.firstWhere((c) => c.id == courseId);
    
    // Check if member has existing credit
    if (member.accountBalance > 0) {
      final creditToUse = member.accountBalance >= amount ? amount : member.accountBalance;
      member.accountBalance -= creditToUse;
      amount -= creditToUse;
      
      if (creditToUse > 0) {
        Get.snackbar(
          'credit_applied'.tr.split('@name')[0],
          'credit_applied'.trParams({'name': member.name, 'amount': creditToUse.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }    
    await _memberRepository.updateMember(member);
  }

  Future<List<Payment>> getPaymentsByMember(String memberId) async {
    return await _repository.getPaymentsByMember(memberId);
  }

  Future<List<Payment>> getPaymentsByCourse(String courseId) async {
    return await _repository.getPaymentsByCourse(courseId);
  }
}