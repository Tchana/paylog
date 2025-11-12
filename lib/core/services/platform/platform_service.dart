// This file uses conditional imports to ensure only the correct platform implementation
// is compiled for each target platform

import 'unified_service_interface.dart';

// Conditional imports - only one will be included in the compiled output
import 'unified_service_mobile.dart'
    if (dart.library.html) 'unified_service_web.dart';

/// A unified service that provides platform-specific functionality
/// This approach ensures that only the relevant implementation is compiled
/// for each target platform, avoiding dart:html import issues on mobile
class PlatformService {
  static UnifiedServiceInterface? _instance;

  static UnifiedServiceInterface get instance {
    _instance ??= _createService();
    return _instance!;
  }

  static UnifiedServiceInterface _createService() {
    // On mobile platforms, UnifiedServiceMobile will be available
    // On web platforms, UnifiedServiceWeb will be available
    // The conditional import ensures only the correct one is compiled
    return UnifiedServiceMobile();
  }
}
