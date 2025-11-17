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
import 'package:paylog/core/services/payment_allocator.dart';

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
      final allocator = Get.find<PaymentAllocator>();
      final payment = await allocator.allocateAndRecordPayment(
        memberId: memberId,
        programId: programId,
        amount: amount,
        date: date,
        description: description,
      );
      payments.add(payment);

      final memberController = Get.find<MemberController>();
      await memberController.fetchMemberPayments(memberId);
      if (memberController.members.isNotEmpty) {
        await memberController.fetchMembersByProgramId(
            memberController.members.first.programId);
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
