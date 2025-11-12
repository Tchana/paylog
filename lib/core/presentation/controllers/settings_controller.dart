import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/services/platform/platform_service_factory.dart';
import 'package:paylog/core/services/platform/data_export_service_interface.dart';
import 'package:paylog/core/services/platform/data_import_service_interface.dart';
import 'package:paylog/core/services/platform/report_service_interface.dart';

class SettingsController extends GetxController {
  late DataExportServiceInterface _exportService;
  late DataImportServiceInterface _importService;
  late ReportServiceInterface _reportService;

  var isExporting = false.obs;
  var isImporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize services using the platform service factory
    _exportService = PlatformServiceFactory.createDataExportService();
    _importService = PlatformServiceFactory.createDataImportService();
    _reportService = PlatformServiceFactory.createReportService();
  }

  // Export all data to JSON
  Future<void> exportAllData() async {
    try {
      isExporting.value = true;
      final jsonData = await _exportService.exportAllDataToJson();
      await _exportService.saveAndShareFile(
          jsonData,
          'paylog_export_${DateTime.now().millisecondsSinceEpoch}.json',
          'application/json');
      Get.snackbar(
        'Success',
        'Data exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  // Export payments to CSV
  Future<void> exportPaymentsToCsv() async {
    try {
      isExporting.value = true;
      final csvData = await _exportService.exportPaymentsToCsv();
      await _exportService.saveAndShareFile(csvData,
          'payments_${DateTime.now().millisecondsSinceEpoch}.csv', 'text/csv');
      Get.snackbar(
        'Success',
        'Payments exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export payments: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  // Import data from JSON
  Future<void> importData() async {
    try {
      isImporting.value = true;
      final jsonData = await _importService.selectFileForImport();
      if (jsonData != null) {
        await _importService.importDataFromJson(jsonData);
        Get.snackbar(
          'Success',
          'Data imported successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Refresh all data
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to import data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isImporting.value = false;
    }
  }

  // Generate summary report
  Future<void> generateSummaryReport() async {
    try {
      isExporting.value = true;
      await _reportService.generateSummaryReport();
      Get.snackbar(
        'Success',
        'Summary report generated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
