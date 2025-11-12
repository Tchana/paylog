abstract class DataExportServiceInterface {
  Future<String> exportAllDataToJson();
  Future<String> exportPaymentsToCsv();
  Future<void> saveAndShareFile(String data, String filename, String mimeType);
}
