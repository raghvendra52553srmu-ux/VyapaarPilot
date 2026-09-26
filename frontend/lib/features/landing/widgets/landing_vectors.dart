import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Lightweight custom vector painters for VyapaarPilot landing page.
/// 100% self-contained, high performance, resolution-independent, no external assets.

/// Brand logo mark combining an upward growth pilot chevron with digital payment node
class VyapaarLogoMark extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const VyapaarLogoMark({
    super.key,
    this.size = 32.0,
    this.primaryColor = AppColors.primary,
    this.accentColor = AppColors.paymentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VyapaarLogoPainter(
        primaryColor: primaryColor,
        accentColor: accentColor,
      ),
    );
  }
}

class _VyapaarLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _VyapaarLogoPainter({required this.primaryColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rounded background tile
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.28),
    );
    final bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bgRRect, bgPaint);

    // Left chevron arm (Deep / solid)
    final leftPath = Path()
      ..moveTo(w * 0.26, h * 0.68)
      ..lineTo(w * 0.50, h * 0.30)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.36, h * 0.70)
      ..close();
    final leftPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftPath, leftPaint);

    // Right chevron arm (Payment Blue - ascending)
    final rightPath = Path()
      ..moveTo(w * 0.50, h * 0.30)
      ..lineTo(w * 0.74, h * 0.68)
      ..lineTo(w * 0.64, h * 0.70)
      ..lineTo(w * 0.50, h * 0.48)
      ..close();
    final rightPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightPaint);

    // Growth dot / signal beacon at the apex
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.09, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _VyapaarLogoPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.accentColor != accentColor;
}

/// Storefront abstraction representing Indian small merchant / Kirana
class MerchantStoreVector extends StatelessWidget {
  final double width;
  final double height;

  const MerchantStoreVector({
    super.key,
    this.width = 160.0,
    this.height = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _MerchantStorePainter(),
    );
  }
}

class _MerchantStorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Building body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.35, w * 0.70, h * 0.60),
      const Radius.circular(8.0),
    );
    final bodyPaint = Paint()
      ..color = AppColors.lightBlue.withValues(alpha: 0.6);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Awning (Kirana striped canopy)
    final awningPaintNavy = Paint()..color = AppColors.primary;
    final awningPaintBlue = Paint()..color = AppColors.secondaryBlue;

    const stripes = 5;
    final stripeW = (w * 0.80) / stripes;
    final startX = w * 0.10;

    for (int i = 0; i < stripes; i++) {
      final p = Path()
        ..moveTo(startX + i * stripeW, h * 0.18)
        ..lineTo(startX + (i + 1) * stripeW, h * 0.18)
        ..lineTo(startX + (i + 1) * stripeW + 4, h * 0.35)
        ..lineTo(startX + i * stripeW - 2, h * 0.35)
        ..close();
      canvas.drawPath(p, (i % 2 == 0) ? awningPaintNavy : awningPaintBlue);
    }

    // Doorway / counter
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.38, h * 0.55, w * 0.24, h * 0.40),
      const Radius.circular(4.0),
    );
    final doorPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.85);
    canvas.drawRRect(doorRect, doorPaint);

    // QR Payment Standee counter graphic
    final qrStand = Path()
      ..moveTo(w * 0.68, h * 0.65)
      ..lineTo(w * 0.76, h * 0.65)
      ..lineTo(w * 0.78, h * 0.82)
      ..lineTo(w * 0.66, h * 0.82)
      ..close();
    canvas.drawPath(qrStand, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.72),
      3,
      Paint()..color = AppColors.paymentBlue,
    );

    // Signal waves radiating from the store
    final wavePaint = Paint()
      ..color = AppColors.paymentBlue.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.72, h * 0.60), radius: 14),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.72, h * 0.60), radius: 22),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      wavePaint..color = AppColors.paymentBlue.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dynamic payment data stream connector (raw transactions -> signal beacon)
class PaymentStreamVector extends StatelessWidget {
  final double width;
  final double height;

  const PaymentStreamVector({
    super.key,
    this.width = 120.0,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _PaymentStreamPainter(),
    );
  }
}

class _PaymentStreamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = AppColors.secondaryBlue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(w * 0.3, h * 0.1, w * 0.7, h * 0.9, w, h * 0.5);

    canvas.drawPath(path, linePaint);

    // Glowing transaction packet dots
    final packetPaint1 = Paint()..color = AppColors.secondaryBlue;
    final packetPaint2 = Paint()..color = AppColors.paymentBlue;
    final packetPaint3 = Paint()..color = AppColors.opportunity;

    canvas.drawCircle(Offset(w * 0.22, h * 0.38), 4.0, packetPaint1);
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), 5.0, packetPaint2);
    canvas.drawCircle(Offset(w * 0.78, h * 0.62), 4.5, packetPaint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dynamic voice waveform illustration
class VoiceWaveformVector extends StatelessWidget {
  final double width;
  final double height;
  final Color barColor;

  const VoiceWaveformVector({
    super.key,
    this.width = 140.0,
    this.height = 36.0,
    this.barColor = AppColors.paymentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _VoiceWaveformPainter(barColor: barColor),
    );
  }
}

class _VoiceWaveformPainter extends CustomPainter {
  final Color barColor;

  _VoiceWaveformPainter({required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pattern of wave heights representing multilingual speech pattern
    final heights = [
      0.25,
      0.45,
      0.75,
      0.95,
      0.60,
      0.85,
      0.40,
      0.70,
      0.90,
      0.50,
      0.80,
      0.35,
      0.65,
      0.25,
    ];

    const barWidth = 4.0;
    final spacing = (w - (heights.length * barWidth)) / (heights.length - 1);
    final paint = Paint()
      ..color = barColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < heights.length; i++) {
      final x = i * (barWidth + spacing) + (barWidth / 2);
      final barH = h * heights[i];
      final top = (h - barH) / 2;
      canvas.drawLine(Offset(x, top), Offset(x, top + barH), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) =>
      oldDelegate.barColor != barColor;
}

/// Directional connector arrow for Growth Loop
class FlowStepArrow extends StatelessWidget {
  final bool isVertical;
  final double size;

  const FlowStepArrow({super.key, this.isVertical = false, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isVertical ? Icons.arrow_downward_rounded : Icons.arrow_forward_rounded,
      color: AppColors.secondaryBlue,
      size: size,
    );
  }
}
