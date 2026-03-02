import 'package:flutter/material.dart';

/// Vanelux logo: navy circle with gold "V" + wordmark.
/// [size] = diameter of the V-mark circle (default 30).
/// [dark] = true for use on dark/navy backgrounds; false for light backgrounds.
/// [showText] = show the VANELUX wordmark next to the mark.
class VaneluxLogo extends StatelessWidget {
  final double size;
  final bool dark;
  final bool showText;

  const VaneluxLogo({
    super.key,
    this.size = 30,
    this.dark = true,
    this.showText = true,
  });

  static const _navy = Color(0xFF0B3254);
  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _mark(),
        if (showText) ...[SizedBox(width: size * 0.28), _wordmark()],
      ],
    );
  }

  Widget _mark() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _navy,
        border: Border.all(color: _gold, width: (size * 0.06).clamp(1.0, 2.5)),
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            color: _gold,
            fontSize: size * 0.50,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _wordmark() {
    final sub = dark ? Colors.white54 : _navy.withOpacity(0.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VANELUX',
          style: TextStyle(
            color: _gold,
            fontSize: size * 0.40,
            fontWeight: FontWeight.w800,
            letterSpacing: size * 0.07,
            height: 1.1,
          ),
        ),
        Text(
          'LUXURY TRANSPORTATION',
          style: TextStyle(
            color: sub,
            fontSize: size * 0.155,
            fontWeight: FontWeight.w400,
            letterSpacing: size * 0.04,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
