import 'dart:convert';
import 'dart:html' as html;
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/repositories/program_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';

class DataExportService {
  final ProgramRepository _programRepository = ProgramRepository();
  final CourseRepository _courseRepository = CourseRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  // Convert Program to Map
  Map<String, dynamic> _programToMap(Program program) {
    return {
      'id': program.id,
      'name': program.name,
      'description': program.description,
      'createdAt': program.createdAt.toIso8601String(),
      'updatedAt': program.updatedAt.toIso8601String(),
    };
  }

  // Convert Course to Map
  Map<String, dynamic> _courseToMap(Course course) {
    return {
      'id': course.id,
      'programId': course.programId,
      'name': course.name,
      'fee': course.fee,
      'description': course.description,
      'createdAt': course.createdAt.toIso8601String(),
      'updatedAt': course.updatedAt.toIso8601String(),
    };
  }

  // Convert Member to Map
  Map<String, dynamic> _memberToMap(Member member) {
    return {
      'id': member.id,
      'programId': member.programId,
      'name': member.name,
      'contactInfo': member.contactInfo,
      'accountBalance': member.accountBalance,
      'totalDebt': member.totalDebt,
      'createdAt': member.createdAt.toIso8601String(),
      'updatedAt': member.updatedAt.toIso8601String(),
    };
  }

  // Convert Payment to Map
  Map<String, dynamic> _paymentToMap(Payment payment) {
    return {
      'id': payment.id,
      'memberId': payment.memberId,
      'courseId': payment.courseId,
      'amount': payment.amount,
      'date': payment.date.toIso8601String(),
      'description': payment.description,
      'programId': payment.programId,
      'createdAt': payment.createdAt.toIso8601String(),
      'updatedAt': payment.updatedAt.toIso8601String(),
    };
  }

  // Export all data to JSON
  Future<String> exportAllDataToJson() async {
    final programs = await _programRepository.getAllPrograms();
    final courses = await _courseRepository.getAllCourses();
    final members = await _memberRepository.getAllMembers();
    final payments = await _paymentRepository.getAllPayments();

    final exportData = {
      'programs': programs.map((p) => _programToMap(p)).toList(),
      'courses': courses.map((c) => _courseToMap(c)).toList(),
      'members': members.map((m) => _memberToMap(m)).toList(),
      'payments': payments.map((p) => _paymentToMap(p)).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };

    return jsonEncode(exportData);
  }

  // Export data to CSV
  Future<String> exportPaymentsToCsv() async {
    final payments = await _paymentRepository.getAllPayments();
    final members = await _memberRepository.getAllMembers();
    final courses = await _courseRepository.getAllCourses();

    // Create member map for quick lookup
    final memberMap = {for (var member in members) member.id: member};
    final courseMap = {for (var course in courses) course.id: course};

    final csv = StringBuffer();
    // CSV header
    csv.writeln('Payment ID,Member Name,Course Name,Amount,Date,Description');

    // CSV rows
    for (var payment in payments) {
      final member = memberMap[payment.memberId];
      final course = courseMap[payment.courseId];

      final row = [
        payment.id,
        member?.name ?? 'Unknown',
        course?.name ?? 'General',
        payment.amount.toString(),
        payment.date.toIso8601String(),
        payment.description ?? '',
      ].join(',');

      csv.writeln(row);
    }

    return csv.toString();
  }

  // Download JSON file
  void downloadJsonFile(String jsonData, String filename) {
    final blob = html.Blob([jsonData], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Download CSV file
  void downloadCsvFile(String csvData, String filename) {
    final blob = html.Blob([csvData], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
