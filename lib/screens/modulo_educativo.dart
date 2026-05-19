import 'package:flutter/material.dart';
import '../config/theme.dart';

class ModuloEducativoScreen extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String videoPath; // Para futuro: 'assets/videos/intro.mp4'
  final String informacion;
  final List<Map<String, String>> puntosClave;

  const ModuloEducativoScreen({
    super.key,
    required this.titulo,
    required this.descripcion,
    this.videoPath = '',
    required this.informacion,
    required this.puntosClave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video (placeholder por ahora)
            _buildVideoPlaceholder(),

            const SizedBox(height: 20),

            // Descripción
            Text(
              descripcion,
              style: const TextStyle(fontSize: 16, color: AppTheme.cafe, height: 1.5),
            ),

            const SizedBox(height: 20),

            // Información detallada
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9EE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                informacion,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),

            const SizedBox(height: 20),

            // Puntos clave
            const Text(
              '📌 Puntos clave',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Fredoka', color: AppTheme.verde),
            ),
            const SizedBox(height: 10),
            ...puntosClave.map((punto) => _buildPuntoClave(punto)),

            const SizedBox(height: 30),

            // Botón de "Entendido"
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('¡Entendido! ✅'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.verde.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, size: 60, color: AppTheme.verde),
          const SizedBox(height: 8),
          const Text(
            'Video próximamente',
            style: TextStyle(fontSize: 16, color: AppTheme.cafe),
          ),
          const SizedBox(height: 4),
          Text(
            'Lola te explicará este tema 🪱',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPuntoClave(Map<String, String> punto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppTheme.verde,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(punto['emoji'] ?? '✅', style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punto['titulo'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  punto['descripcion'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppTheme.cafe),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}