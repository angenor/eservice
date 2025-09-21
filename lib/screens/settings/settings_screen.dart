import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(l10n.appearance),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text(l10n.theme),
                  subtitle: Text(_getThemeName(themeProvider.themeMode, l10n)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showThemeDialog(context, themeProvider, l10n),
                ),
              ],
            ),
          ),
          _buildSectionHeader(l10n.general),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text(_getLanguageName(localeProvider.locale, l10n)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageDialog(context, localeProvider, l10n),
                ),
              ],
            ),
          ),
          _buildSectionHeader(l10n.about),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.version),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                  },
                ),
              ],
            ),
          ),
          _buildSectionHeader(l10n.help),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(l10n.help),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l10n.contactUs),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemMode;
    }
  }

  String _getLanguageName(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.english;
      case 'fr':
        return l10n.french;
      default:
        return l10n.english;
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked
                ),
                title: Text(l10n.lightMode),
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked
                ),
                title: Text(l10n.darkMode),
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.system
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked
                ),
                title: Text(l10n.systemMode),
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  localeProvider.locale.languageCode == 'en'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked
                ),
                title: Text(l10n.english),
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  localeProvider.locale.languageCode == 'fr'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked
                ),
                title: Text(l10n.french),
                onTap: () {
                  localeProvider.setLocale(const Locale('fr'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}