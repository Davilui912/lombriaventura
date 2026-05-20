import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/monedas_service.dart';

class HistorialMonedasScreen extends StatelessWidget {
  const HistorialMonedasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MonedasService();
    final historial = service.obtenerHistorial();
    final saldo = service.obtenerSaldo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 Historial'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text('$saldo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: historial.isEmpty
          ? const Center(child: Text('Sin movimientos aún 📭'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final mov = historial[index];
                final esGanancia = mov['tipo'] == 'ganancia';
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      esGanancia ? Icons.arrow_upward : Icons.arrow_downward,
                      color: esGanancia ? AppTheme.verde : Colors.red,
                    ),
                    title: Text(mov['concepto']),
                    trailing: Text(
                      '${esGanancia ? "+" : "-"}${mov['cantidad']} 🪙',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: esGanancia ? AppTheme.verde : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}