abstract class DataImportServiceInterface {
  Future<void> importDataFromJson(String jsonData);
  Future<String?> selectFileForImport();
}
