import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/settings.dart';
import '../models/timer_model.dart';
import '../utils/l10n/app_localizations.dart';
import '../widgets/glassmorphic_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _sendFeedback(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'swingcoder@gmail.com',
      queryParameters: {'subject': localizations.feedbackEmailSubject},
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: GlassmorphicContainer(
                width: double.infinity,
                height: 60,
                borderRadius: 12,
                blur: 10,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.4),
                          ]
                          : [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.9),
                          ],
                ),
                borderColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.6),
                shadowColor: Colors.transparent,
                child: Center(
                  child: Text(
                    localizations.feedbackEmailError,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              elevation: 0,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.feedbackEmailError)),
        );
      }
    }
  }

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
