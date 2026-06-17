import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/recordatorios_service.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  late RecordatoriosService _service;
  List<Map<String, dynamic>> _pendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializarServicio();
  }

  Future<void> _inicializarServicio() async {
    _service = RecordatoriosService();
    await _service.init();  // ✅ Inicializar antes de usar
    _cargarPendientes();
  }

  void _cargarPendientes() {
    setState(() {
      _pendientes = _service.obtenerPendientes();
      _isLoading = false;
    });
  }

  Future<void> _marcarVisto(String id) async {
    await _service.marcarVisto(id);
    _cargarPendientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⏰ Recordatorios'),
        backgroundColor: AppTheme.verde,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendientes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: AppTheme.verde),
                      SizedBox(height: 16),
                      Text(
                        '¡No hay recordatorios pendientes!',
                        style: TextStyle(fontSize: 18, color: AppTheme.verde),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendientes.length,
                  itemBuilder: (context, index) {
                    final item = _pendientes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text(
                          item['icono'] ?? '📌',
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          item['titulo'] ?? 'Recordatorio',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item['mensaje'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle, color: AppTheme.verde),
                          onPressed: () => _marcarVisto(item['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}