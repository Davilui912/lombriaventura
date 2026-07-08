import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, dynamic> _datosUsuario = {};
  List<Map<String, dynamic>> _capacitados = [];
  int _monedas = 0;
  int _estrellas = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final configBox = await Hive.openBox('configuracion');
    final capacitacionesBox = await Hive.openBox('capacitaciones');
    final monedasBox = await Hive.openBox('monedas');
    final logrosBox = await Hive.openBox('logros');

    setState(() {
      _datosUsuario = {
        'nombre': configBox.get('usuario_nombre', defaultValue: 'No registrado'),
        'edad': configBox.get('usuario_edad', defaultValue: '?'),
        'ciudad': configBox.get('usuario_ciudad', defaultValue: '?'),
        'fecha': configBox.get('usuario_fecha_registro', defaultValue: ''),
      };
      _capacitados = List<Map<String, dynamic>>.from(
        capacitacionesBox.get('capacitados', defaultValue: [])
      );
      _monedas = monedasBox.get('total', defaultValue: 0);
      _estrellas = logrosBox.get('estrellas', defaultValue: 0);
    });
  }

  Future<void> _reiniciarDatos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reiniciar datos?'),
        content: const Text('Esto borrará todo el progreso del usuario. ¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reiniciar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final configBox = await Hive.openBox('configuracion');
      final capacitacionesBox = await Hive.openBox('capacitaciones');
      final monedasBox = await Hive.openBox('monedas');
      final logrosBox = await Hive.openBox('logros');
      final accesoriosBox = await Hive.openBox('accesorios');

      await configBox.clear();
      await capacitacionesBox.clear();
      await monedasBox.clear();
      await logrosBox.clear();
      await accesoriosBox.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos reiniciados'), backgroundColor: Colors.orange),
      );
      _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 Panel Admin'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen
          Card(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('📊 Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildFila('👤 Usuario', _datosUsuario['nombre']),
                  _buildFila('🪙 Monedas', '$_monedas'),
                  _buildFila('⭐ Estrellas', '$_estrellas'),
                  _buildFila('🎓 Capacitados', '${_capacitados.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Capacitados
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.school, color: Colors.orange),
              title: const Text('Capacitados'),
              children: _capacitados.isEmpty
                  ? [const Padding(padding: EdgeInsets.all(16), child: Text('No hay capacitados registrados'))]
                  : _capacitados.map((cap) => ListTile(
                      title: Text(cap['nombre']),
                      subtitle: Text('${cap['edad']} años • ${cap['municipio']}, ${cap['estado']}'),
                      trailing: Text(cap['fecha'].toString().substring(0, 10)),
                    )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botones de acción
          ElevatedButton.icon(
            onPressed: _cargarDatos,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar datos'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _reiniciarDatos,
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Reiniciar todos los datos'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor),
        ],
      ),
    );
  }
}