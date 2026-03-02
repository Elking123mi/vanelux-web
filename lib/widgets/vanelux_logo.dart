import 'package:flutter/material.dart';

/// Vanelux branded logo widget â€” gold "V" in dark circle + "VANELUX" text.
/// Use [size] to scale the whole thing (default 40).
/// [dark] = true  â†’ dark header (navy bg), white subtitle text.
/// [dark] = false â†’ light background (white/grey), navy subtitle text.
class VaneluxLogo extends StatelessWidget {
  final double size;
  final bool dark; // dark=true â†’ white header; dark=false â†’ light background
  final bool showText;

  const VaneluxLogo({
    super.key,
    this.size = 40,
    this.dark = true,
    this.showText = true,
  });

  static const _navyBlue = Color(0xFF0B3254);
  static const _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMark(),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          _buildWordmark(),
        ],
      ],
    );
  }

  Widget _buildMark() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _navyBlue,
        border: Border.all(color: _gold, width: size * 0.04),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.2),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.02,
          )
        ],
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            color: _gold,
            fontSize: size * 0.52,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildWordmark() {
    final textColor = dark ? Colors.white : _navyBlue;
    final subtitleColor = dark ? Colors.white60 : _navyBlue.withOpacity(0.55);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'VANELUX',
          style: TextStyle(
            color: _gold,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            letterSpacing: size * 0.06,
          ),
        ),
        Text(
          'LUXURY TRANSPORTATION',
          style: TextStyle(
            color: subtitleColor,
            fontSize: size * 0.17,
            fontWeight: FontWeight.w400,
            letterSpacing: size * 0.03,
          ),
        ),
      ],
    );
  }
}

