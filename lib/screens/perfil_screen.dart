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
  String _usuario = '';
  String _nombreCompleto = '';
  String _edad = '';
  String _ciudad = '';
  String _genero = 'Lola';
  String _fechaRegistro = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() => _isLoading = true);
    
    try {
      final configBox = await Hive.openBox('configuracion');
      
      setState(() {
        _usuario = configBox.get('usuario_actual', defaultValue: '');
        _nombreCompleto = configBox.get('usuario_nombre', defaultValue: 'Lombrikid');
        _edad = configBox.get('usuario_edad', defaultValue: '?');
        _ciudad = configBox.get('usuario_ciudad', defaultValue: '?');
        _genero = configBox.get('usuario_genero', defaultValue: 'Lola');
        _fechaRegistro = configBox.get('usuario_fecha_registro', defaultValue: DateTime.now().toIso8601String());
        _isLoading = false;
      });
      
      debugPrint('✅ Perfil cargado: usuario=$_usuario, nombre=$_nombreCompleto, genero=$_genero');
    } catch (e) {
      debugPrint('❌ Error cargando perfil: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cerrar sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final configBox = await Hive.openBox('configuracion');
      await configBox.clear();
      
      debugPrint('🗑️ Sesión cerrada, datos limpiados');
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  String _formatearFecha(String fechaIso) {
    if (fechaIso.isEmpty) return 'Hoy';
    try {
      final fecha = DateTime.parse(fechaIso);
      final ahora = DateTime.now();
      final diff = ahora.difference(fecha).inDays;
      if (diff == 0) return 'Hoy';
      if (diff == 1) return 'Ayer';
      return 'Hace $diff días';
    } catch (e) {
      return 'Reciente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final generoIcon = _genero == 'Lola' ? Icons.female : Icons.male;
    final generoColor = _genero == 'Lola' ? Colors.pink : AppTheme.azulCielo;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: generoColor.withValues(alpha: 0.2),
                    child: Icon(
                      generoIcon,
                      size: 60,
                      color: generoColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nombreCompleto,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: generoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _genero == 'Lola' ? '🪱 Lombriz Lola' : '🪱 Lombriz Lalo',
                      style: TextStyle(color: generoColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Nombre de usuario
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.badge, color: AppTheme.verde),
                      title: const Text('Nombre de usuario'),
                      subtitle: Text(_usuario.isEmpty ? 'Sin definir' : _usuario),
                    ),
                  ),
                  
                  // Nombre completo
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person, color: AppTheme.verde),
                      title: const Text('Nombre completo'),
                      subtitle: Text(_nombreCompleto),
                    ),
                  ),
                  
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cake, color: AppTheme.verde),
                      title: const Text('Edad'),
                      subtitle: Text('$_edad años'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_city, color: AppTheme.verde),
                      title: const Text('Ciudad'),
                      subtitle: Text(_ciudad),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppTheme.verde),
                      title: const Text('Lombrikid desde'),
                      subtitle: Text(_formatearFecha(_fechaRegistro)),
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
                            'Completa actividades y juegos para seguir aprendiendo. ¡Sigue ayudando al planeta! 🌱',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}