// data/repositories/payment_repository.dart
import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/data/models/payment.dart';

class PaymentRepository {
  Future<List<Payment>> getAllPayments() async {
    return HiveService.payments.values.toList();
  }

  Future<List<Payment>> getPaymentsByProgram(String programId) async {
    return HiveService.payments.values
        .where((payment) => payment.programId == programId)
        .toList();
  }

  Future<List<Payment>> getPaymentsByMember(String memberId) async {
    return HiveService.payments.values
        .where((payment) => payment.memberId == memberId)
        .toList();
  }

  Future<List<Payment>> getPaymentsByCourse(String courseId) async {
    return HiveService.payments.values
        .where((payment) => payment.courseId == courseId)
        .toList();
  }

  Future<void> addPayment(Payment payment) async {
    await HiveService.payments.put(payment.id, payment);
  }

  Future<void> updatePayment(Payment payment) async {
    await HiveService.payments.put(payment.id, payment);
  }

  Future<void> deletePayment(String paymentId) async {
    await HiveService.payments.delete(paymentId);
  }

  Future<double> getTotalCollectedByProgram(String programId) async {
    final programPayments = await getPaymentsByProgram(programId);
    return programPayments.fold<double>(
        0, (sum, payment) => sum + payment.amount);
  }

  Future<List<Payment>> getRecentPayments({int limit = 10}) async {
    final allPayments = await getAllPayments();
    allPayments.sort((a, b) => b.date.compareTo(a.date));
    return allPayments.take(limit).toList();
  }
}
