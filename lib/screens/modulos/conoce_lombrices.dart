import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/contenido_lombrices.dart';

class ConoceLombricesScreen extends StatelessWidget {
  const ConoceLombricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conoce a las lombrices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leccionesLombrices.length,
        itemBuilder: (context, index) {
          final leccion = leccionesLombrices[index];
          return _buildLeccionCard(leccion);
        },
      ),
    );
  }

  Widget _buildLeccionCard(LeccionLombriz leccion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(leccion.icono, size: 40, color: AppTheme.verde),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    leccion.titulo,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cafe,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              leccion.contenido,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            if (leccion.datosCuriosos != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.amarillo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, size: 20, color: AppTheme.amarillo),
                        SizedBox(width: 8),
                        Text(
                          '✨ Dato curioso',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var dato in leccion.datosCuriosos!)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text('• $dato'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}