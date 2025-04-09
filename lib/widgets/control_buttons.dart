import 'package:flutter/material.dart';
import 'package:tomato_app/utils/l10n/app_localizations.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isRunning ? onPause : onStart,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isRunning
                ? AppLocalizations.of(context)!.pauseButton
                : AppLocalizations.of(context)!.startButton,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.resetButton,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
