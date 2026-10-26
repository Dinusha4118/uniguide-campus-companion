import 'package:flutter/material.dart';

class BrandLogoWidget extends StatelessWidget {
  final double size;
  final bool showShadow;
  final double? borderRadius;

  const BrandLogoWidget({
    super.key,
    this.size = 72.0,
    this.showShadow = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.24);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0D253F).withOpacity(0.18),
                  blurRadius: size * 0.16,
                  offset: Offset(0, size * 0.06),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/images/uniguide_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
