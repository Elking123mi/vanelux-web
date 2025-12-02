import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Widget de debug para mostrar la configuración actual del backend
class BackendConfigDebug extends StatelessWidget {
  const BackendConfigDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔧 DEBUG - Configuración Backend',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'URL Base: ${AppConfig.apiBaseUrl}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Bookings: ${AppConfig.vlxBookingsUrl}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            _getPlatformInfo(),
            style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _getPlatformInfo() {
    if (AppConfig.apiBaseUrl.contains('localhost')) {
      return '💻 Plataforma: Desktop/Web (localhost)';
    } else {
      return '📱 Plataforma: Móvil (IP: ${AppConfig.apiBaseUrl})';
    }
  }
}
