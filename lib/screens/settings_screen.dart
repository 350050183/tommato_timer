import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../models/timer_model.dart';
import '../utils/l10n/app_localizations.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void updateSettingAndTimer(
    BuildContext context,
    Function() updateFunction,
  ) async {
    await updateFunction();
    if (context.mounted) {
      // 更新计时器模型的设置
      Provider.of<TimerModel>(context, listen: false).updateSettings(
        Provider.of<SettingsModel>(context, listen: false).settings,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settingsModel = Provider.of<SettingsModel>(context);
    final timerModel = Provider.of<TimerModel>(context);
    final settings = settingsModel.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 计时器设置
            _buildSectionHeader(context, localizations.timerSettings),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  _buildDurationSetting(
                    context,
                    title: localizations.workDuration,
                    value: settings.workDurationMinutes,
                    onChanged: (value) {
                      updateSettingAndTimer(
                        context,
                        () => settingsModel.setWorkDuration(value),
                      );
                    },
                  ),
                  _buildDurationSetting(
                    context,
                    title: localizations.shortBreakDuration,
                    value: settings.shortBreakDurationMinutes,
                    onChanged: (value) {
                      updateSettingAndTimer(
                        context,
                        () => settingsModel.setShortBreakDuration(value),
                      );
                    },
                  ),
                  _buildDurationSetting(
                    context,
                    title: localizations.longBreakDuration,
                    value: settings.longBreakDurationMinutes,
                    onChanged: (value) {
                      updateSettingAndTimer(
                        context,
                        () => settingsModel.setLongBreakDuration(value),
                      );
                    },
                  ),
                  _buildDurationSetting(
                    context,
                    title: localizations.sessionsBeforeLongBreak,
                    value: settings.sessionsBeforeLongBreak,
                    suffix: localizations.sessions,
                    onChanged: (value) {
                      updateSettingAndTimer(
                        context,
                        () => settingsModel.setSessionsBeforeLongBreak(value),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 通知设置
            _buildSectionHeader(context, localizations.notificationSettings),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(localizations.enableNotifications),
                    value: settings.notificationsEnabled,
                    onChanged: (bool value) {
                      settingsModel.setNotificationsEnabled(value);
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.enableVibration),
                    value: settings.vibrationEnabled,
                    onChanged: (bool value) {
                      settingsModel.setVibrationEnabled(value);
                    },
                  ),
                ],
              ),
            ),

            // 显示设置
            _buildSectionHeader(context, localizations.displaySettings),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(localizations.keepScreenOn),
                    value: settings.keepScreenOn,
                    onChanged: (value) {
                      updateSettingAndTimer(
                        context,
                        () => settingsModel.setKeepScreenOn(value),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: Text(localizations.darkMode),
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      updateSettingAndTimer(
                        context,
                        () => settingsModel.setDarkMode(value),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(localizations.language),
                    trailing: DropdownButton<String>(
                      value: settings.locale,
                      items: [
                        DropdownMenuItem(
                          value: 'auto',
                          child: Text(localizations.systemDefault),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(localizations.english),
                        ),
                        DropdownMenuItem(
                          value: 'zh',
                          child: Text(localizations.chinese),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          updateSettingAndTimer(
                            context,
                            () => settingsModel.setLocale(value),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 关于
            _buildSectionHeader(context, localizations.appInfo),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(localizations.aboutButton),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDurationSetting(
    BuildContext context, {
    required String title,
    required int value,
    String suffix = '',
    required Function(int) onChanged,
  }) {
    final localizations = AppLocalizations.of(context);
    suffix = suffix.isEmpty ? localizations.minutes : suffix;

    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text('$value $suffix', style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
