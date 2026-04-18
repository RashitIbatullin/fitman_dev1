import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BodySilhouettePainter extends CustomPainter {
  final AnthropometryMeasurement measurement;
  final int? height;

  BodySilhouettePainter({required this.measurement, this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.shade200
      ..style = PaintingStyle.fill;

    // --- 1. Get Data and Handle Nulls ---
    final double personHeight = (height?.toDouble() ?? 175.0);
    final shoulders = measurement.shouldersCirc?.toDouble() ?? 100;
    final bust = measurement.breastCirc?.toDouble() ?? 90;
    final waist = measurement.waistCirc?.toDouble() ?? 70;
    final hips = measurement.hipsCirc?.toDouble() ?? 95;

    // --- 2. Calculate Widths from Circumferences ---
    // Approximation: width = circumference / PI
    final shoulderWidth = shoulders / math.pi;
    final bustWidth = bust / math.pi;
    final waistWidth = waist / math.pi;
    final hipWidth = hips / math.pi;

    // --- 3. Establish Scale and Proportions ---
    final scale = size.height / personHeight;
    final bodyWidthScale = size.width / 100; 

    final sW = shoulderWidth * bodyWidthScale * 0.8; 
    final bW = bustWidth * bodyWidthScale * 0.8;
    final wW = waistWidth * bodyWidthScale * 0.8;
    final hW = hipWidth * bodyWidthScale * 0.8;

    final centerX = size.width / 2;

    // Vertical positions are now relative to the canvas size, but could be scaled too
    final neckY = size.height * 0.12;
    final shoulderY = size.height * 0.18;
    final bustY = size.height * 0.28;
    final waistY = size.height * 0.40;
    final hipY = size.height * 0.52;
    final crotchY = size.height * 0.60;
    final feetY = size.height;

    // --- 4. Define Body Path ---
    final Path path = Path();
    
    // LEFT SIDE
    path.moveTo(centerX - sW / 4, neckY); 
    path.quadraticBezierTo(centerX - sW / 2.2, shoulderY - 5, centerX - sW / 2, shoulderY); 
    path.quadraticBezierTo(centerX - bW / 1.8, bustY, centerX - bW/2, bustY); 
    path.quadraticBezierTo(centerX - wW / 2.2, waistY, centerX - wW/2, waistY); 
    path.quadraticBezierTo(centerX - hW / 1.8, hipY, centerX - hW / 2, hipY); 
    path.quadraticBezierTo(centerX - wW/3, crotchY, centerX - 5, crotchY); 
    path.lineTo(centerX - 5, feetY - 20); 
    path.quadraticBezierTo(centerX, feetY, centerX, feetY); 
    
    // RIGHT SIDE
    path.lineTo(centerX, feetY); 
    path.quadraticBezierTo(centerX, feetY, centerX + 5, feetY - 20); 
    path.lineTo(centerX + 5, crotchY); 
    path.quadraticBezierTo(centerX + wW/3, crotchY, centerX + hW / 2, hipY); 
    path.quadraticBezierTo(centerX + hW / 1.8, hipY, centerX + bW/2, bustY); 
    path.quadraticBezierTo(centerX + sW / 2.2, shoulderY - 5, centerX + sW / 4, neckY); 
    
    path.close();

    canvas.drawPath(path, paint);
    
    // --- 5. Draw Head ---
    canvas.drawCircle(Offset(centerX, neckY - (size.height * 0.06)), size.height * 0.06 * (scale > 0 ? scale : 1), paint);

  }

  @override
  bool shouldRepaint(covariant BodySilhouettePainter oldDelegate) {
    return oldDelegate.measurement != measurement || oldDelegate.height != height;
  }
}
