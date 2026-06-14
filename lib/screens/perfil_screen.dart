import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic> _usuario = {};
  int _diasActivos = 0;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final box = await Hive.openBox('configuracion');
    setState(() {
      _usuario = {
        'nombre': box.get('usuario_nombre', defaultValue: 'Lombikid'),
        'edad': box.get('usuario_edad', defaultValue: '?'),
        'ciudad': box.get('usuario_ciudad', defaultValue: '?'),
        'fecha_registro': box.get('usuario_fecha_registro', defaultValue: DateTime.now().toIso8601String()),
      };
    });
  }

    Future<void> _cerrarSesion() async {
    final box = await Hive.openBox('usuarios');
    await box.delete('usuario_actual');
    await box.delete('usuario_nombre');
    await box.delete('usuario_edad');
    await box.delete('usuario_ciudad');
    
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    }

  @override
  Widget build(BuildContext context) {
    final fechaRegistro = DateTime.tryParse(_usuario['fecha_registro'] ?? '');
    final dias = fechaRegistro != null ? DateTime.now().difference(fechaRegistro).inDays : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppTheme.verde,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.verde.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 60, color: AppTheme.verde),
            ),
            const SizedBox(height: 16),
            Text(
              _usuario['nombre'],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Lombikid',
                style: TextStyle(color: AppTheme.verde, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cake, color: AppTheme.verde),
                title: const Text('Edad'),
                subtitle: Text('${_usuario['edad']} años'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city, color: AppTheme.verde),
                title: const Text('Ciudad'),
                subtitle: Text(_usuario['ciudad']),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: AppTheme.verde),
                title: const Text('Lombikid desde'),
                subtitle: Text(_formatearFecha(_usuario['fecha_registro'])),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.amber),
                title: const Text('Días activos'),
                subtitle: Text('$dias días'),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.verde),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Completa actividades y juegos para ganar monedas y accesorios. ¡Sigue ayudando al planeta! 🌱',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Reciente';
    try {
      final fecha = DateTime.parse(fechaIso);
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (e) {
      return 'Reciente';
    }
  }
}