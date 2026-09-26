import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AudioWaveIndicator extends StatefulWidget {
  final Color color;
  final double height;
  final bool isPulsing;

  const AudioWaveIndicator({
    super.key,
    this.color = AppColors.secondaryBlue,
    this.height = 20.0,
    this.isPulsing = true,
  });

  @override
  State<AudioWaveIndicator> createState() => _AudioWaveIndicatorState();
}

class _AudioWaveIndicatorState extends State<AudioWaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBar((_controller.value * 0.8 + 0.2)),
            const SizedBox(width: 3.0),
            _buildBar(((1.0 - _controller.value) * 0.9 + 0.1)),
            const SizedBox(width: 3.0),
            _buildBar((_controller.value * 1.0 + 0.2)),
            const SizedBox(width: 3.0),
            _buildBar(((1.0 - _controller.value) * 0.7 + 0.3)),
            const SizedBox(width: 3.0),
            _buildBar((_controller.value * 0.6 + 0.4)),
          ],
        );
      },
    );
  }

  Widget _buildBar(double factor) {
    final barHeight = (widget.height * factor).clamp(4.0, widget.height);
    return Container(
      width: 3.5,
      height: barHeight,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }
}
