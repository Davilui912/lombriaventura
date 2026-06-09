import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';

class VentasHistorialScreen extends StatefulWidget {
  const VentasHistorialScreen({super.key});

  @override
  State<VentasHistorialScreen> createState() => _VentasHistorialScreenState();
}

class _VentasHistorialScreenState extends State<VentasHistorialScreen> {
  final MonedasService _monedasService = MonedasService();
  List<Map<String, dynamic>> _historial = [];
  int _totalGanado = 0;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    await _monedasService.init();
    setState(() {
      _historial = _monedasService.obtenerHistorial();
      // Filtrar solo ventas (descripciones que contengan "Vendiste")
      _totalGanado = _historial
          .where((item) => item['descripcion'].contains('Vendiste'))
          .fold(0, (sum, item) => sum + (item['cantidad'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ventas = _historial.where((item) => item['descripcion'].contains('Vendiste')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de ventas'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: [
                const Text(
                  '💰 Total ganado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  '$_totalGanado',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          Expanded(
            child: ventas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay ventas registradas aún.\n¡Vende lombrices o atomizadores!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventas[index];
                      final cantidad = venta['cantidad'] as int;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(alpha: 0.2),
                            child: const Icon(Icons.attach_money, color: Colors.orange),
                          ),
                          title: Text(venta['descripcion']),
                          subtitle: Text(
                            _formatearFecha(venta['fecha']),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '+$cantidad',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String fechaIso) {
    final fecha = DateTime.parse(fechaIso);
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}