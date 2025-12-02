import 'package:flutter/material.dart';

class RouteMapView extends StatelessWidget {
  const RouteMapView({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    this.strokeColor,
    this.strokeWeight,
  });

  final String originLabel;
  final String destinationLabel;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? strokeColor;
  final double? strokeWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF10223D),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Text(
        'La vista de mapa está disponible desde la versión web.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      ),
    );
  }
}
