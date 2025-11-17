import 'dart:convert';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:paylog/core/services/platform/unified_service_interface.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/models/program.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/program_repository.dart';

class UnifiedServiceWeb implements UnifiedServiceInterface {
  final MemberRepository _memberRepository = MemberRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final CourseRepository _courseRepository = CourseRepository();
  final ProgramRepository _programRepository = ProgramRepository();

  // Data export methods
  @override
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

  @override
  Future<String> exportPaymentsToCsv() async {
    final payments = await _paymentRepository.getAllPayments();
    final members = await _memberRepository.getAllMembers();
    final courses = await _courseRepository.getAllCourses();

    // Create member map for quick lookup
    final memberMap = {for (var member in members) member.id: member};
    final courseMap = {for (var course in courses) course.id: course};

    final csv = StringBuffer();
    csv.writeln(_csvRow([
      'Payment ID',
      'Member Name',
      'Course Name',
      'Amount',
      'Date',
      'Description'
    ]));

    // CSV rows
    for (var payment in payments) {
      final member = memberMap[payment.memberId];
      final course = courseMap[payment.courseId];

      csv.writeln(_csvRow([
        payment.id,
        member?.name ?? 'Unknown',
        course?.name ?? 'General',
        payment.amount.toString(),
        payment.date.toIso8601String(),
        payment.description ?? '',
      ]));
    }

    return csv.toString();
  }

  @override
  Future<void> saveAndShareFile(
      String data, String filename, String mimeType) async {
    final blob = html.Blob([data], mimeType);
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

  // Data import methods
  @override
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
        await _paymentRepository.addPayment(payment);
      }
    }
  }

  @override
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

  // Report methods
  @override
  Future<void> generateMemberPaymentReport(Member member) async {
    final payments = await _paymentRepository.getPaymentsByMember(member.id);
    final courses = await _courseRepository.getAllCourses();

    // Create course map for lookup
    final courseMap = {for (var course in courses) course.id: course};

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Payment Report for ${member.name}',
                  style: const pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Account Balance: ${member.accountBalance.toStringAsFixed(2)}'),
                  pw.Text('Total Debt: ${member.totalDebt.toStringAsFixed(2)}'),
                  pw.Text(
                      'Pending Balance: ${member.pendingBalance.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Payment History',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Course', 'Amount', 'Description'],
                data: payments.map((payment) {
                  final course = payment.courseId != null
                      ? courseMap[payment.courseId]
                      : null;
                  return [
                    '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                    course?.name ?? 'General Payment',
                    payment.amount.toStringAsFixed(2),
                    payment.description ?? '',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Report Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'payment_report_${member.name.replaceAll(' ', '_')}.pdf';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<void> generateSummaryReport() async {
    final payments = await _paymentRepository.getAllPayments();
    final members = await _memberRepository.getAllMembers();
    final courses = await _courseRepository.getAllCourses();

    // Create maps for lookup
    final memberMap = {for (var member in members) member.id: member};
    final courseMap = {for (var course in courses) course.id: course};

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          // Calculate summary statistics
          double totalPayments = 0;
          for (var payment in payments) {
            totalPayments += payment.amount;
          }

          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Payment Summary Report',
                  style: const pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text(
                    'Total Payments: ${payments.length}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Total Amount: ${totalPayments.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Payment Details',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Member', 'Course', 'Amount', 'Date'],
                data: payments.map((payment) {
                  final member = memberMap[payment.memberId];
                  final course = payment.courseId != null
                      ? courseMap[payment.courseId]
                      : null;
                  return [
                    member?.name ?? 'Unknown',
                    course?.name ?? 'General Payment',
                    payment.amount.toStringAsFixed(2),
                    '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Report Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download =
          'summary_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Helper methods
  Map<String, dynamic> _programToMap(Program program) {
    return {
      'id': program.id,
      'name': program.name,
      'description': program.description,
      'createdAt': program.createdAt.toIso8601String(),
      'updatedAt': program.updatedAt.toIso8601String(),
    };
  }

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
}

String _csvValue(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

String _csvRow(List<String> values) =>
    values.map((value) => _csvValue(value)).join(',');
