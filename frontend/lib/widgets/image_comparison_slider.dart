import 'package:flutter/material.dart';

class ImageComparisonSlider extends StatefulWidget {
  final Widget before;
  final Widget after;

  const ImageComparisonSlider({
    super.key,
    required this.before,
    required this.after,
  });

  @override
  State<ImageComparisonSlider> createState() => _ImageComparisonSliderState();
}

class _ImageComparisonSliderState extends State<ImageComparisonSlider> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderPosition = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Before Image
              widget.before,
              // After Image (clipped)
              ClipRect(
                clipper: _ImageClipper(clipFactor: _sliderPosition),
                child: widget.after,
              ),
              // Slider Handle
              Positioned(
                left: width * _sliderPosition - 2, // Center the line
                top: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                ),
              ),
              Positioned(
                left: width * _sliderPosition - 22, // Center the thumb
                top: height / 2 - 22,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha((0.7 * 255).round()),
                  ),
                  child: const Icon(
                    Icons.unfold_more,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double clipFactor;

  _ImageClipper({required this.clipFactor});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * clipFactor, size.height);
  }

  @override
  bool shouldReclip(covariant _ImageClipper oldClipper) {
    return oldClipper.clipFactor != clipFactor;
  }
}
