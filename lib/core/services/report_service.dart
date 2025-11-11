import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:paylog/data/models/member.dart';
import 'package:paylog/data/models/payment.dart';
import 'package:paylog/data/models/course.dart';
import 'package:paylog/data/repositories/member_repository.dart';
import 'package:paylog/data/repositories/payment_repository.dart';
import 'package:paylog/data/repositories/course_repository.dart';
import 'package:paylog/core/presentation/controllers/member_controller.dart';

class ReportService {
  final MemberRepository _memberRepository = MemberRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final CourseRepository _courseRepository = CourseRepository();

  // Generate member payment report PDF
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
                  style: pw.TextStyle(fontSize: 24),
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
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Report Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
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

  // Generate summary report for all payments
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
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text(
                    'Total Payments: ${payments.length}',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Total Amount: ${totalPayments.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 16),
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
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Report Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
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
}