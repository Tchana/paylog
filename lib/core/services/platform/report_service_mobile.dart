import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:paylog/core/services/platform/report_service_interface.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/data/repositories/enrollment_repository.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportServiceMobile implements ReportServiceInterface {
  final MemberRepository _memberRepository = MemberRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final CourseRepository _courseRepository = CourseRepository();

  @override
  Future<void> generateMemberPaymentReport(Member member) async {
    final payments = await _paymentRepository.getPaymentsByMember(member.id);
    final courses = await _courseRepository.getAllCourses();
    final enrollments = await EnrollmentRepository().getEnrollmentsByMember(member.id);

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
                  style: pw.TextStyle(
                    fontSize: 24,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Account Balance: ${member.accountBalance.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: pw.Font.helvetica()),
                  ),
                  pw.Text(
                    'Total Debt: ${member.totalDebt.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: pw.Font.helvetica()),
                  ),
                  pw.Text(
                    'Pending Balance: ${member.pendingBalance.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: pw.Font.helvetica()),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Payment History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Course', 'Amount', 'Description'],
                data: [
                  for (final payment in payments)
                    if (payment.autoAssignedCourses.isNotEmpty)
                      ...payment.autoAssignedCourses.map((a) => [
                            '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                            a.courseName,
                            a.amountApplied.toStringAsFixed(2),
                            payment.description ?? '',
                          ])
                    else
                      [
                        '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                        'General Payment',
                        payment.amount.toStringAsFixed(2),
                        payment.description ?? '',
                      ]
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Per-course Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Course', 'Fee', 'Paid', 'Balance'],
                data: enrollments.map((enrollment) {
                  final course = courseMap[enrollment.courseId];
                  final fee = course?.fee ?? 0.0;
                  final paid = enrollment.amountPaid;
                  final balance = (fee - paid).clamp(0, double.infinity);
                  return [
                    course?.name ?? 'Course',
                    fee.toStringAsFixed(2),
                    paid.toStringAsFixed(2),
                    balance.toStringAsFixed(2),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Report Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey,
                  font: pw.Font.helvetica(),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save and share the PDF
    await _saveAndSharePdf(
        pdf, 'payment_report_${member.name.replaceAll(' ', '_')}.pdf');
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
                  style: pw.TextStyle(
                    fontSize: 24,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text(
                    'Total Payments: ${payments.length}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      font: pw.Font.helvetica(),
                    ),
                  ),
                  pw.Text(
                    'Total Amount: ${totalPayments.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      font: pw.Font.helvetica(),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Payment Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
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
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Report Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey,
                  font: pw.Font.helvetica(),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save and share the PDF
    await _saveAndSharePdf(
        pdf, 'summary_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // Save and share PDF
  Future<void> _saveAndSharePdf(pw.Document pdf, String filename) async {
    try {
      final bytes = await pdf.save();

      // Try to get the application documents directory
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final file = io.File(filePath);

        await file.writeAsBytes(bytes);
        await Share.shareFiles([filePath], subject: filename);
      } catch (pathException) {
        // If we can't get the documents directory, try to use a temporary directory
        try {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$filename';
          final file = io.File(filePath);

          await file.writeAsBytes(bytes);
          await Share.shareFiles([filePath], subject: filename);
        } catch (tempException) {
          // If both fail, rethrow the original path exception
          throw pathException;
        }
      }
    } catch (e) {
      // Re-throw the exception so it can be handled by the calling code
      rethrow;
    }
  }
}

ReportServiceInterface createReportService() => ReportServiceMobile();
