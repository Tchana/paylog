import 'package:paylog/data/models/member.dart';

abstract class UnifiedServiceInterface {
  // Data export methods
  Future<String> exportAllDataToJson();
  Future<String> exportPaymentsToCsv();
  Future<void> saveAndShareFile(String data, String filename, String mimeType);

  // Data import methods
  Future<void> importDataFromJson(String jsonData);
  Future<String?> selectFileForImport();

  // Report methods
  Future<void> generateMemberPaymentReport(Member member);
  Future<void> generateSummaryReport();
}
