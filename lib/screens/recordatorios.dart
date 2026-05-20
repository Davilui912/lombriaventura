import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/recordatorios_service.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final RecordatoriosService _service = RecordatoriosService();
  late List<Map<String, dynamic>> _pendientes;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _pendientes = _service.obtenerPendientes();
    });
  }

  void _marcarVisto(String id) {
    _service.marcarVisto(id);
    _cargar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ ¡Buen trabajo, Eco Héroe!'),
        backgroundColor: AppTheme.verde,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⏰ Recordatorios'),
        actions: [
          if (_pendientes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendientes.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: _pendientes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Todo al día!',
                    style: TextStyle(fontSize: 26, fontFamily: 'Fredoka', color: AppTheme.verde),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No tienes recordatorios pendientes.\n¡Eres un gran cuidador! 🌱',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendientes.length,
              itemBuilder: (context, index) {
                final rec = _pendientes[index];
                return _buildRecordatorioCard(rec);
              },
            ),
    );
  }

  Widget _buildRecordatorioCard(Map<String, dynamic> rec) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.verde.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(rec['icono'], style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec['titulo'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cada ${rec['frecuenciaDias']} días',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rec['mensaje'],
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.cafe),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _marcarVisto(rec['id']),
                icon: const Icon(Icons.check, size: 20),
                label: const Text('¡Hecho!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}