import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:paylog/core/presentation/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late String _selectedLanguage;
  String _selectedCurrency = '₣';
  late bool _isDarkMode;
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _getDeviceLocaleTag();
    _isDarkMode = _isDeviceDarkMode();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage =
          prefs.getString('language') ?? _getDeviceLocaleTag();
      _selectedCurrency = prefs.getString('currency') ?? '₣';
      _isDarkMode = prefs.getBool('darkMode') ?? _isDeviceDarkMode();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('currency', _selectedCurrency);
    await prefs.setBool('darkMode', _isDarkMode);
  }

  String _getDeviceLocaleTag() {
    final locale =
        Get.deviceLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
    final language = locale.languageCode;
    final country = locale.countryCode?.isNotEmpty == true
        ? locale.countryCode!
        : 'US';
    return '${language}_${country.toUpperCase()}';
  }

  bool _isDeviceDarkMode() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'app_settings'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildLanguageSelector(),
                    const Divider(),
                    _buildCurrencySelector(),
                    const Divider(),
                    _buildDarkModeToggle(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'data_management'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildExportDataButton(),
                    const SizedBox(height: 16),
                    _buildExportPaymentsButton(),
                    const SizedBox(height: 16),
                    _buildImportDataButton(),
                    const SizedBox(height: 16),
                    _buildGenerateReportButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('language'.tr),
        DropdownButton<String>(
          value: _selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'en_US', child: Text('English')),
            DropdownMenuItem(value: 'fr_FR', child: Text('Français')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
              _saveSettings();
              // Update app language
              Get.updateLocale(Locale(_selectedLanguage.split('_')[0],
                  _selectedLanguage.split('_')[1]));
            }
          },
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('currency'.tr),
        DropdownButton<String>(
          value: _selectedCurrency,
          items: const [
            DropdownMenuItem(value: '₣', child: Text('₣ (Francs CFA)')),
            DropdownMenuItem(value: '€', child: Text('€ (Euro)')),
            DropdownMenuItem(value: '\$', child: Text('\$ (Dollar)')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCurrency = value;
              });
              _saveSettings();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('dark_mode'.tr),
        Switch(
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
            _saveSettings();
            // Update app theme
            Get.changeThemeMode(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
          },
        ),
      ],
    );
  }

  Widget _buildExportDataButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: settingsController.isExporting.value
              ? null
              : () => settingsController.exportAllData(),
          icon: settingsController.isExporting.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text('export_data'.tr),
        ));
  }

  Widget _buildExportPaymentsButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: settingsController.isExporting.value
              ? null
              : () => settingsController.exportPaymentsToCsv(),
          icon: settingsController.isExporting.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.table_chart),
          label: Text('export_payments'.tr),
        ));
  }

  Widget _buildImportDataButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: settingsController.isImporting.value
              ? null
              : () => settingsController.importData(),
          icon: settingsController.isImporting.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload),
          label: Text('import_data'.tr),
        ));
  }

  Widget _buildGenerateReportButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: settingsController.isExporting.value
              ? null
              : () => settingsController.generateSummaryReport(),
          icon: settingsController.isExporting.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text('generate_report'.tr),
        ));
  }
}
