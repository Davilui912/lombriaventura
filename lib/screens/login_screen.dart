import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'menu_principal.dart';
import 'registro_screen.dart';
import 'recuperar_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final box = await Hive.openBox('configuracion');
    final usuarioActual = box.get('usuario_actual');
    
    if (usuarioActual != null) {
      _irAlMenu();
    }
  }

  Future<void> _iniciarSesion() async {
    if (_usernameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu nombre de usuario');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final box = await Hive.openBox('usuarios');
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      
      final usuariosRaw = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
      
      // ✅ Convertir correctamente los datos
      final List<Map<String, dynamic>> usuarios = [];
      for (var item in usuariosRaw) {
        if (item is Map) {
          final map = <String, dynamic>{};
          item.forEach((key, value) {
            map[key.toString()] = value;
          });
          usuarios.add(map);
        }
      }
      
      // ✅ Buscar por 'usuario' (no por 'nombre')
      Map<String, dynamic>? usuarioEncontrado;
      for (var u in usuarios) {
        if (u['usuario'] == username && u['password'] == password) {
          usuarioEncontrado = u;
          break;
        }
      }

      if (usuarioEncontrado != null) {
        final configBox = await Hive.openBox('configuracion');
        
        // ✅ Guardar datos de sesión
        await configBox.put('usuario_actual', username);
        await configBox.put('usuario_nombre', usuarioEncontrado['nombre'] ?? username);
        await configBox.put('usuario_edad', usuarioEncontrado['edad']?.toString() ?? '?');
        await configBox.put('usuario_ciudad', usuarioEncontrado['ciudad'] ?? '?');
        await configBox.put('usuario_genero', usuarioEncontrado['genero'] ?? 'Lola');
        await configBox.put('usuario_fecha_registro', usuarioEncontrado['fechaRegistro'] ?? DateTime.now().toIso8601String());
        
        debugPrint('✅ Usuario conectado: $username');
        
        _irAlMenu();
      } else {
        // ✅ Verificar si el usuario existe pero la contraseña es incorrecta
        final usernameExiste = usuarios.any((u) => u['usuario'] == username);
        if (usernameExiste) {
          setState(() {
            _errorMessage = '❌ Contraseña incorrecta';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = '❌ Usuario no registrado';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión: $e';
        _isLoading = false;
      });
    }
  }

  void _irAlMenu() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MenuPrincipal()),
      (route) => false,
    );
  }

  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
  }

  void _irARecuperarPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecuperarPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.verde, AppTheme.fondo],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_lombriaventura.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bug_report, size: 60, color: AppTheme.verde),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lombriaventura',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¡Bienvenido de vuelta!',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre de usuario',
                            prefixIcon: const Icon(Icons.person, color: AppTheme.verde),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock, color: AppTheme.verde),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _irARecuperarPassword,
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppTheme.verde)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.verde,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                : const Text('Ingresar', style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: _irARegistro,
                              child: const Text('Regístrate', style: TextStyle(color: AppTheme.verde)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}