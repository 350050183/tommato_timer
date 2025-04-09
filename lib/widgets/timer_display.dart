import 'package:flutter/material.dart';

class TimerDisplay extends StatefulWidget {
  final Duration remainingTime;
  final bool isRunning;

  const TimerDisplay({
    super.key,
    required this.remainingTime,
    required this.isRunning,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black12 : Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            _formatTime(widget.remainingTime),
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: widget.isRunning
                  ? Theme.of(context).primaryColor
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black45),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
