import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paylog/core/services/data_export_service.dart';
import 'package:paylog/core/services/data_import_service.dart';
import 'package:paylog/core/services/report_service.dart';

class SettingsController extends GetxController {
  final DataExportService _exportService = DataExportService();
  final DataImportService _importService = DataImportService();
  final ReportService _reportService = ReportService();

  var isExporting = false.obs;
  var isImporting = false.obs;

  // Export all data to JSON
  Future<void> exportAllData() async {
    try {
      isExporting.value = true;
      final jsonData = await _exportService.exportAllDataToJson();
      _exportService.downloadJsonFile(jsonData,
          'paylog_export_${DateTime.now().millisecondsSinceEpoch}.json');
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
      _exportService.downloadCsvFile(
          csvData, 'payments_${DateTime.now().millisecondsSinceEpoch}.csv');
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
