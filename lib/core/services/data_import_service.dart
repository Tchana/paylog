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

class DataImportService {
  final ProgramRepository _programRepository = ProgramRepository();
  final CourseRepository _courseRepository = CourseRepository();
  final MemberRepository _memberRepository = MemberRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  // Import data from JSON
  Future<void> importDataFromJson(String jsonData) async {
    final data = jsonDecode(jsonData);

    // Clear existing data first
    await _clearAllData();

    // Import programs
    if (data['programs'] != null) {
      for (var programData in data['programs']) {
        final program = Program(
          id: programData['id'],
          name: programData['name'],
          description: programData['description'],
        );
        // Set timestamps
        // Note: We can't directly set createdAt/updatedAt for Hive objects
        await _programRepository.addProgram(program);
      }
    }

    // Import courses
    if (data['courses'] != null) {
      for (var courseData in data['courses']) {
        final course = Course(
          id: courseData['id'],
          programId: courseData['programId'],
          name: courseData['name'],
          fee: courseData['fee'].toDouble(),
          description: courseData['description'],
        );
        // Set timestamps
        await _courseRepository.addCourse(course);
      }
    }

    // Import members
    if (data['members'] != null) {
      for (var memberData in data['members']) {
        final member = Member(
          id: memberData['id'],
          programId: memberData['programId'],
          name: memberData['name'],
          contactInfo: memberData['contactInfo'],
          accountBalance: memberData['accountBalance'].toDouble(),
          totalDebt: memberData['totalDebt'].toDouble(),
        );
        // Set timestamps
        await _memberRepository.addMember(member);
      }
    }

    // Import payments
    if (data['payments'] != null) {
      for (var paymentData in data['payments']) {
        final payment = Payment(
          id: paymentData['id'],
          memberId: paymentData['memberId'],
          courseId: paymentData['courseId'],
          amount: paymentData['amount'].toDouble(),
          date: DateTime.parse(paymentData['date']),
          description: paymentData['description'],
          programId: paymentData['programId'],
        );
        // Set timestamps
        await _paymentRepository.addPayment(payment);
      }
    }
  }

  // Clear all data
  Future<void> _clearAllData() async {
    // Get all data first
    final programs = await _programRepository.getAllPrograms();
    final courses = await _courseRepository.getAllCourses();
    final members = await _memberRepository.getAllMembers();
    final payments = await _paymentRepository.getAllPayments();

    // Delete all payments
    for (var payment in payments) {
      await _paymentRepository.deletePayment(payment.id);
    }

    // Delete all members
    for (var member in members) {
      await _memberRepository.deleteMember(member.id);
    }

    // Delete all courses
    for (var course in courses) {
      await _courseRepository.deleteCourse(course.id);
    }

    // Delete all programs
    for (var program in programs) {
      await _programRepository.deleteProgram(program.id);
    }
  }

  // Select file for import
  Future<String?> selectFileForImport() async {
    final input = html.FileUploadInputElement()..accept = '.json';
    input.click();

    await input.onChange.first;

    if (input.files!.isEmpty) return null;

    final file = input.files!.first;
    final reader = html.FileReader();

    reader.readAsText(file);
    await reader.onLoad.first;

    return reader.result as String?;
  }
}
