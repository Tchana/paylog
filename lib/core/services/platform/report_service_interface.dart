import 'package:paylog/data/models/member.dart';

abstract class ReportServiceInterface {
  Future<void> generateMemberPaymentReport(Member member);
  Future<void> generateSummaryReport();
}
