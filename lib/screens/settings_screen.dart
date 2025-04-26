import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../utils/l10n/app_localizations.dart';
import '../widgets/glassmorphic_background.dart';
import '../widgets/glassmorphic_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final settingsModel = Provider.of<SettingsModel>(context);
    final settings = settingsModel.settings;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: GlassmorphicBackground(
        useGradient: true,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      l10n.notifications,
                      [
                        _buildSwitchTile(
                          context,
                          l10n.enableNotifications,
                          settings.notificationsEnabled,
                          (value) =>
                              settingsModel.setNotificationsEnabled(value),
                        ),
                        _buildSwitchTile(
                          context,
                          l10n.enableVibration,
                          settings.vibrationEnabled,
                          (value) => settingsModel.setVibrationEnabled(value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      l10n.display,
                      [
                        _buildSwitchTile(
                          context,
                          l10n.keepScreenOn,
                          settings.keepScreenOn,
                          (value) => settingsModel.setKeepScreenOn(value),
                        ),
                        _buildLanguageTile(context, l10n, settingsModel),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      l10n.about,
                      [
                        _buildAboutTile(context, l10n),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GlassmorphicContainer(
      width: double.infinity,
      height: children.length * 60.0 + 60.0,
      borderRadius: 20,
      blur: 10,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ]
            : [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.4),
              ],
      ),
      borderColor: isDarkMode
          ? Colors.white.withOpacity(0.2)
          : Colors.white.withOpacity(0.5),
      shadowColor: isDarkMode
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    AppLocalizations l10n,
    SettingsModel settingsModel,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        l10n.language,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: DropdownButton<String>(
        value: settingsModel.settings.locale,
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text(l10n.english),
          ),
          DropdownMenuItem(
            value: 'zh',
            child: Text(l10n.chinese),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            settingsModel.setLocale(value);
          }
        },
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context, AppLocalizations l10n) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        l10n.about,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, '/about');
      },
    );
  }
}
