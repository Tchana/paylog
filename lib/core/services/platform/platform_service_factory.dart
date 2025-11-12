import 'data_export_service_interface.dart';
import 'report_service_interface.dart';
import 'data_import_service_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import both mobile and web implementations
import 'data_export_service_mobile.dart';
import 'data_export_service_web.dart';
import 'report_service_mobile.dart';
import 'report_service_web.dart';
import 'data_import_service_mobile.dart';
import 'data_import_service_web.dart';

class PlatformServiceFactory {
  static DataExportServiceInterface createDataExportService() {
    // Return the appropriate implementation based on the platform
    if (kIsWeb) {
      return DataExportServiceWeb();
    } else {
      return DataExportServiceMobile();
    }
  }

  static ReportServiceInterface createReportService() {
    // Return the appropriate implementation based on the platform
    if (kIsWeb) {
      return ReportServiceWeb();
    } else {
      return ReportServiceMobile();
    }
  }

  static DataImportServiceInterface createDataImportService() {
    // Return the appropriate implementation based on the platform
    if (kIsWeb) {
      return DataImportServiceWeb();
    } else {
      return DataImportServiceMobile();
    }
  }
}
