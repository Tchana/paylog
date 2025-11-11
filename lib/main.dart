import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paylog/core/app/bindings/initial_binding.dart';
import 'package:paylog/core/app/routes/app_pages.dart';
import 'package:paylog/core/app/theme/app_theme.dart';
import 'package:paylog/core/services/hive_service.dart';
import 'package:paylog/core/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.initialize();

  runApp(const PayLogApp());
}

class PayLogApp extends StatelessWidget {
  const PayLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PayLog',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
    );
  }
}
