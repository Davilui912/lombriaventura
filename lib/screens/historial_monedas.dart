import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/monedas_service.dart';

class HistorialMonedasScreen extends StatefulWidget {
  const HistorialMonedasScreen({super.key});

  @override
  State<HistorialMonedasScreen> createState() => _HistorialMonedasScreenState();
}

class _HistorialMonedasScreenState extends State<HistorialMonedasScreen> {
  final MonedasService _service = MonedasService();
  List<Map<String, dynamic>> _historial = [];
  int _saldo = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _service.init();
    setState(() {
      _historial = _service.obtenerHistorial();
      _saldo = _service.obtenerSaldo();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Monedas'),
        backgroundColor: AppTheme.verde,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Saldo actual
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '💰 Tus Monedas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_saldo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Historial
                Expanded(
                  child: _historial.isEmpty
                      ? const Center(
                          child: Text(
                            'Aún no has ganado monedas.\n¡Juega y completa actividades!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _historial.length,
                          itemBuilder: (context, index) {
                            final item = _historial[index];
                            final cantidad = item['cantidad'] as int;
                            final esGanancia = cantidad > 0;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: esGanancia
                                      ? AppTheme.verde.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                                  child: Icon(
                                    esGanancia ? Icons.add : Icons.remove,
                                    color: esGanancia ? AppTheme.verde : Colors.red,
                                  ),
                                ),
                                title: Text(item['descripcion']),
                                subtitle: Text(
                                  _formatearFecha(item['fecha']),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  '${esGanancia ? '+' : ''}${cantidad}',
                                  style: TextStyle(
                                    color: esGanancia ? AppTheme.verde : Colors.red,
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
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);
    
    if (diff.inDays == 0) {
      return 'Hoy, ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}