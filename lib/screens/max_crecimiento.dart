
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/actividad_service.dart';

class MaxCrecimientoScreen extends StatelessWidget {
  const MaxCrecimientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actividadService = ActividadService();
    final fase = actividadService.obtenerFaseMax();
    final dias = actividadService.obtenerDiasActivos();
    final racha = actividadService.obtenerRacha();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌳 Max Manzanero'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Árbol animado
              _buildArbol(fase),

              const SizedBox(height: 30),

              // Nombre de la fase
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.verde,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Fase ${fase['fase']}: ${fase['nombre']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'Fredoka',
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Descripción
              Text(
                fase['descripcion'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.cafe),
              ),

              const SizedBox(height: 30),

              // Estadísticas
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.verde.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _buildEstadistica('📏 Altura', '${fase['altura']} cm'),
                    const SizedBox(height: 12),
                    _buildEstadistica('📅 Días de actividad', '$dias días'),
                    const SizedBox(height: 12),
                    _buildEstadistica('🔥 Racha actual', '$racha días seguidos'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mensaje motivacional
              if (fase['fase'] == 5)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.amarillo.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 30)),
                      SizedBox(width: 10),
                      Text(
                        '¡Max llegó a su máximo!\nEres un Eco Héroe',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafe),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArbol(Map<String, dynamic> fase) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Column(
            children: [
              Text(fase['emoji'], style: TextStyle(fontSize: 80 + (fase['fase'] as int) * 20)),
              const SizedBox(height: 10),
              // Tronco que crece según la fase
              Container(
                width: 20 + (fase['fase'] as int) * 8.0,
                height: 40 + (fase['fase'] as int) * 25.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEstadistica(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.verde,
            fontFamily: 'Fredoka',
          ),
        ),
      ],
    );
  }
}