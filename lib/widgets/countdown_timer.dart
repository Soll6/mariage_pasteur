import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;

  const CountdownTimer({super.key, required this.targetDate});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = widget.targetDate.difference(now);
      if (_remaining.isNegative) {
        _remaining = Duration.zero;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CountdownBox(value: days.toString(), label: 'Jours'),
        _CountdownBox(value: hours.toString().padLeft(2, '0'), label: 'Heures'),
        _CountdownBox(value: minutes.toString().padLeft(2, '0'), label: 'Min'),
        _CountdownBox(value: seconds.toString().padLeft(2, '0'), label: 'Sec'),
      ],
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppColors.onTertiaryFixed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: AppColors.onTertiaryFixedVariant,
            ),
          ),
        ],
      ),
    );
  }
}
