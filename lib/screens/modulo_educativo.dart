import 'package:flutter/material.dart';
import '../config/theme.dart';

class ModuloEducativoScreen extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String informacion;
  final List<Map<String, String>> puntosClave;

  const ModuloEducativoScreen({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.informacion,
    required this.puntosClave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: AppTheme.verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.amarillo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 30, color: AppTheme.amarillo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      descripcion,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '📖 Información',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.cafe,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              informacion,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              '✨ Puntos clave',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.cafe,
              ),
            ),
            const SizedBox(height: 12),
            ...puntosClave.map((punto) => _buildPuntoClave(
                  punto['emoji'] ?? '📌',
                  punto['titulo'] ?? '',
                  punto['descripcion'] ?? '',
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPuntoClave(String emoji, String titulo, String descripcion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}