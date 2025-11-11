import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedLanguage = 'en_US';
  String _selectedCurrency = '₣';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en_US';
      _selectedCurrency = prefs.getString('currency') ?? '₣';
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('currency', _selectedCurrency);
    await prefs.setBool('darkMode', _isDarkMode);
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
                    _buildImportDataButton(),
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
          items: [
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
              Get.updateLocale(Locale(_selectedLanguage.split('_')[0]!,
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
          items: [
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
    return ElevatedButton.icon(
      onPressed: () {
        // Export data functionality
        Get.snackbar(
          'Info',
          'Export data functionality would be implemented here',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      icon: const Icon(Icons.download),
      label: Text('export_data'.tr),
    );
  }

  Widget _buildImportDataButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Import data functionality
        Get.snackbar(
          'Info',
          'Import data functionality would be implemented here',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      icon: const Icon(Icons.upload),
      label: Text('import_data'.tr),
    );
  }
}
