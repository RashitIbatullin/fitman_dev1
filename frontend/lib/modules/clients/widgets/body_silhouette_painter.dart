import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BodySilhouettePainter extends CustomPainter {
  final AnthropometryMeasurement measurement;
  final int? height;
  final Color? silhouetteColor; // New parameter

  BodySilhouettePainter({required this.measurement, this.height, this.silhouetteColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = silhouetteColor ?? Colors.blueGrey.shade200 // Use provided color or default
      ..style = PaintingStyle.fill;
    
    // Line paint for arms and legs
    final linePaint = Paint()
      ..color = silhouetteColor?.withAlpha((255 * 0.6).round()) ?? Colors.blueGrey.shade400 // Use provided color with alpha for lines
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // --- 1. Get Data and Handle Nulls ---
    final double personHeightCm = (height?.toDouble() ?? 175.0); // Assuming height is in cm
    final shouldersCirc = measurement.shouldersCirc?.toDouble() ?? 100;
    final breastCirc = measurement.breastCirc?.toDouble() ?? 90;
    final waistCirc = measurement.waistCirc?.toDouble() ?? 70;
    final hipsCirc = measurement.hipsCirc?.toDouble() ?? 95;

    // --- 2. Calculate Widths from Circumferences ---
    // Approximation: width = circumference / PI
    final shoulderWidthCm = shouldersCirc / math.pi;
    final bustWidthCm = breastCirc / math.pi;
    final waistWidthCm = waistCirc / math.pi;
    final hipWidthCm = hipsCirc / math.pi;

    // --- 3. Establish Scale and Proportions ---
    // Use 80% of canvas height as reference for actual person height, leaving space for head above and some margin below
    final double silhouetteReferenceHeightPixels = size.height * 0.8; 
    final double silhouetteScale = silhouetteReferenceHeightPixels / personHeightCm; // Pixels per cm

    // Vertical positions derived from real-world proportions, then scaled
    final double headHeightCm = personHeightCm * 0.125; // Approx 1/8 of height for head
    final double headRadiusCm = headHeightCm / 2;

    final double neckTopYCm = headHeightCm;
    final double shoulderTopYCm = personHeightCm * 0.20; // Slightly lower than head for neck
    final double bustTopYCm = personHeightCm * 0.28;
    final double waistTopYCm = personHeightCm * 0.40;
    final double hipsTopYCm = personHeightCm * 0.52;
    final double crotchTopYCm = personHeightCm * 0.60; 
    // final double kneeTopYCm = personHeightCm * 0.78;    
    // Convert CM positions to Canvas Y coordinates (pixels)
    // We add an offset to center the head at the top of the silhouetteReferenceHeightPixels
    final double topOffsetPixels = (size.height - silhouetteReferenceHeightPixels) / 2; 

    final double headCenterY = (headRadiusCm * silhouetteScale) + topOffsetPixels;
    final double neckY = (neckTopYCm * silhouetteScale) + topOffsetPixels;
    final double shoulderY = (shoulderTopYCm * silhouetteScale) + topOffsetPixels;
    final double bustY = (bustTopYCm * silhouetteScale) + topOffsetPixels;
    final double waistY = (waistTopYCm * silhouetteScale) + topOffsetPixels;
    final double hipsY = (hipsTopYCm * silhouetteScale) + topOffsetPixels;
    final double crotchY = (crotchTopYCm * silhouetteScale) + topOffsetPixels;
    // final double kneeY = (kneeTopYCm * silhouetteScale) + topOffsetPixels;
    final double feetY = size.height; // Feet at the bottom of the canvas

    // Scaled widths in pixels
    final double sW = shoulderWidthCm * silhouetteScale * 0.9; // Adjusted for visual appeal
    final double bW = bustWidthCm * silhouetteScale * 0.9; // Adjusted for visual appeal
    final double wW = waistWidthCm * silhouetteScale * 0.9; // Adjusted for visual appeal
    final double hW = hipWidthCm * silhouetteScale * 0.9; // Adjusted for visual appeal
    
    final double centerX = size.width / 2;

    // --- 4. Define Body Path (Torso and Hips) ---
    final Path bodyPath = Path();
    
    // LEFT SIDE
    bodyPath.moveTo(centerX - sW / 4, neckY); 
    bodyPath.quadraticBezierTo(centerX - sW / 2, shoulderY, centerX - sW / 2, shoulderY); 
    bodyPath.quadraticBezierTo(centerX - bW / 2, bustY, centerX - bW/2, bustY); 
    bodyPath.quadraticBezierTo(centerX - wW / 2, waistY, centerX - wW/2, waistY); 
    bodyPath.quadraticBezierTo(centerX - hW / 2, hipsY, centerX - hW / 2, hipsY); 
    bodyPath.lineTo(centerX - hW / 2, crotchY); // Straight down to crotch

    // RIGHT SIDE
    bodyPath.lineTo(centerX + hW / 2, crotchY); // Straight from left crotch to right crotch
    bodyPath.quadraticBezierTo(centerX + hW / 2, hipsY, centerX + hW / 2, hipsY); 
    bodyPath.quadraticBezierTo(centerX + wW / 2, waistY, centerX + wW/2, waistY); 
    bodyPath.quadraticBezierTo(centerX + bW / 2, bustY, centerX + bW/2, bustY); 
    bodyPath.quadraticBezierTo(centerX + sW / 2, shoulderY, centerX + sW / 4, neckY); 
    
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
    
    // --- 5. Draw Head ---
    canvas.drawCircle(Offset(centerX, headCenterY), headRadiusCm * silhouetteScale, paint);

    // --- 6. Draw Arms (schematic) ---
    final double armLengthCm = personHeightCm * 0.3; // Approx length of arm
    final double armWidthCm = personHeightCm * 0.03; // Approx width of arm

    final double elbowY = shoulderY + (armLengthCm * 0.5 * silhouetteScale);
    final double handY = shoulderY + (armLengthCm * silhouetteScale);

    // Left arm
    canvas.drawLine(Offset(centerX - sW / 2, shoulderY), Offset(centerX - sW / 2 - (armWidthCm * silhouetteScale * 2), elbowY), linePaint);
    canvas.drawLine(Offset(centerX - sW / 2 - (armWidthCm * silhouetteScale * 2), elbowY), Offset(centerX - sW / 2 - (armWidthCm * silhouetteScale * 2), handY), linePaint);

    // Right arm
    canvas.drawLine(Offset(centerX + sW / 2, shoulderY), Offset(centerX + sW / 2 + (armWidthCm * silhouetteScale * 2), elbowY), linePaint);
    canvas.drawLine(Offset(centerX + sW / 2 + (armWidthCm * silhouetteScale * 2), elbowY), Offset(centerX + sW / 2 + (armWidthCm * silhouetteScale * 2), handY), linePaint);


    // --- 7. Draw Legs (schematic to knees) ---
    final double legWidthCm = personHeightCm * 0.1; // Approx width of leg (adjusted to be more visible)
    final double legHalfWidth = (legWidthCm * silhouetteScale) / 2;

    // Left leg
    canvas.drawLine(Offset(centerX - legHalfWidth, crotchY), Offset(centerX - legHalfWidth, feetY), linePaint);
    // Right leg
    canvas.drawLine(Offset(centerX + legHalfWidth, crotchY), Offset(centerX + legHalfWidth, feetY), linePaint);

  }

  @override
  bool shouldRepaint(covariant BodySilhouettePainter oldDelegate) {
    return oldDelegate.measurement != measurement || oldDelegate.height != height || oldDelegate.silhouetteColor != silhouetteColor;
  }
}
