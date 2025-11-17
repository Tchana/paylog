import 'data_export_service_interface.dart';
import 'data_import_service_interface.dart';
import 'report_service_interface.dart';

import 'data_export_service_mobile.dart'
    if (dart.library.html) 'data_export_service_web.dart'
        as data_export_service;
import 'data_import_service_mobile.dart'
    if (dart.library.html) 'data_import_service_web.dart'
        as data_import_service;
import 'report_service_mobile.dart'
    if (dart.library.html) 'report_service_web.dart' as report_service;

class PlatformServiceFactory {
  static DataExportServiceInterface createDataExportService() {
    return data_export_service.createDataExportService();
  }

  static ReportServiceInterface createReportService() {
    return report_service.createReportService();
  }

  static DataImportServiceInterface createDataImportService() {
    return data_import_service.createDataImportService();
  }
}
