import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';

class ActualizacionService {
  static const String _androidId = 'com.lombriaventura.app';

  Future<void> verificarActualizacion(BuildContext context) async {
    try {
      final newVersion = NewVersionPlus(
        androidId: _androidId,
      );

      final status = await newVersion.getVersionStatus();

      if (!context.mounted) return;

      if (status != null && status.canUpdate) {
        _mostrarDialogoActualizacion(
          context,
          newVersion: newVersion,
          localVersion: status.localVersion,
          storeVersion: status.storeVersion,
          appStoreLink: status.appStoreLink,
        );
      }
    } catch (e) {
      debugPrint('Error al verificar actualización: $e');
    }
  }

  void _mostrarDialogoActualizacion(
    BuildContext context, {
    required NewVersionPlus newVersion,
    required String localVersion,
    required String storeVersion,
    required String appStoreLink,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🚀 ¡Nueva actualización!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hay una nueva versión de Lombriaventura disponible. '
              'Actualiza para disfrutar de las últimas mejoras y correcciones.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Versión instalada: $localVersion',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Versión nueva: $storeVersion',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              newVersion.launchAppStore(appStoreLink);
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.download, color: Colors.white, size: 18),
            label: const Text(
              'Actualizar ahora',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}