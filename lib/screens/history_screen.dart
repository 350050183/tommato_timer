import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/timer_model.dart';
import '../utils/app_theme.dart';
import '../utils/l10n/app_localizations.dart';
import '../widgets/glassmorphic_background.dart';
import '../widgets/glassmorphic_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timerModel = Provider.of<TimerModel>(context);
    final history = timerModel.history;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: GlassmorphicContainer(
          width: 180,
          height: 48,
          borderRadius: 24,
          blur: 10,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    AppTheme.darkGlassColor.withOpacity(0.1),
                    AppTheme.darkGlassColor.withOpacity(0.2),
                  ]
                : [
                    AppTheme.lightGlassColor.withOpacity(0.6),
                    AppTheme.lightGlassColor.withOpacity(0.7),
                  ],
          ),
          borderColor: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.5),
          shadowColor: Colors.transparent,
          child: Center(
            child: Text(
              l10n.historyTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: history.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDarkMode
                            ? AppTheme.darkGlassColor.withOpacity(0.7)
                            : AppTheme.lightGlassColor.withOpacity(
                                0.8,
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                        title: Text(l10n.clearHistory),
                        content: Text('确定要清空所有历史记录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              timerModel.clearHistory();
                              Navigator.pop(context);
                            },
                            child: Text(l10n.save),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: GlassmorphicBackground(
        child: SafeArea(
          child: history.isEmpty
              ? Center(
                  child: GlassmorphicContainer(
                    width: 250,
                    height: 80,
                    borderRadius: 15,
                    blur: 10,
                    border: 1,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              AppTheme.darkGlassColor.withOpacity(0.1),
                              AppTheme.darkGlassColor.withOpacity(0.2),
                            ]
                          : [
                              AppTheme.lightGlassColor.withOpacity(0.6),
                              AppTheme.lightGlassColor.withOpacity(0.7),
                            ],
                    ),
                    borderColor: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.5),
                    shadowColor: Colors.transparent,
                    child: Center(
                      child: Text(
                        l10n.noHistoryMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[history.length - 1 - index]; // 倒序显示
                    return HistoryListItem(item: item);
                  },
                ),
        ),
      ),
    );
  }
}

class HistoryListItem extends StatelessWidget {
  final TimerHistory item;

  const HistoryListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(item.timestamp);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    String sessionType;
    Color sessionColor;

    switch (item.type) {
      case TimerType.work:
        sessionType = l10n.workSession;
        sessionColor = AppTheme.primaryColor;
        break;
      case TimerType.shortBreak:
        sessionType = l10n.shortBreak;
        sessionColor = AppTheme.secondaryColor;
        break;
      case TimerType.longBreak:
        sessionType = l10n.longBreak;
        sessionColor = AppTheme.accentColor;
        break;
    }

    // 计算实际持续时间的格式化字符串
    final int minutes = item.actualDurationSeconds ~/ 60;
    final int seconds = item.actualDurationSeconds % 60;
    final String actualDurationText =
        '$minutes ${l10n.minutes} $seconds ${l10n.seconds}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 150,
        borderRadius: 16,
        blur: 10,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            sessionColor.withOpacity(isDarkMode ? 0.05 : 0.1),
            sessionColor.withOpacity(isDarkMode ? 0.15 : 0.2),
          ],
        ),
        borderColor: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.5),
        shadowColor: sessionColor.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: sessionColor.withOpacity(
                    isDarkMode ? 0.2 : 0.3,
                  ),
                  child: Icon(Icons.timer, color: sessionColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sessionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.durationMinutes} ${l10n.minutes}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sessionColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.hourglass_bottom,
                  size: 18,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.actualDuration}: ',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  actualDurationText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
