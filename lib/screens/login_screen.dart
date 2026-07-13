import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'menu_principal.dart';
import 'registro_screen.dart';
import 'recuperar_password_screen.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart'; // ✅ NUEVO: AuthService sin Firebase

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // ✅ NUEVO
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    try {
      final box = await Hive.openBox('configuracion');
      final loginExitoso = box.get('login_exitoso', defaultValue: false);
      
      // ✅ También verificar si AuthService tiene usuario
      if (loginExitoso) {
        _irAlMenu();
      } else if (loginExitoso) {
        // Si Hive dice que hay sesión pero AuthService no, intentar restaurar
        final usuarioActual = box.get('usuario_actual');
        if (usuarioActual != null) {
          // Intentar obtener usuario de la API
          final result = await ApiService().obtenerUsuario(usuarioActual);
          if (result.ok && result.data != null) {
            // Usuario válido, ir al menú
            _irAlMenu();
          }
        }
      }
    } catch (e) {
      print('❌ Error verificando sesión: $e');
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
      final box = await Hive.openBox('configuracion');
      final nombreUsuario = _usernameController.text.trim();
      final passwordIngresada = _passwordController.text.trim();

      print('🔍 Buscando usuario: $nombreUsuario');

      // ✅ 1. Buscar en Hive PRIMERO (offline)
      final usuarioGuardado = box.get('usuario_actual');
      final passwordGuardada = box.get('usuario_password');

      if (usuarioGuardado == nombreUsuario && passwordGuardada == passwordIngresada) {
        print('✅ Login exitoso desde Hive');
        await box.put('login_exitoso', true);
        // ✅ Restaurar usuario en AuthService
        final result = await ApiService().obtenerUsuario(nombreUsuario);
        if (result.ok && result.data != null) {
          // Guardar en AuthService
          await _authService.login(
            nombreUsuario: nombreUsuario,
            password: passwordIngresada,
          );
        }
        _irAlMenu();
        return;
      }

      // ✅ 2. Buscar en API por nombre de usuario (online)
      final syncService = SyncService();
      if (await syncService.tieneInternet()) {
        print('🌐 Buscando usuario en API por nombre: $nombreUsuario');
        
        try {
          // Usar el nuevo método loginUsuario de ApiService
          final result = await ApiService().loginUsuario(
            nombreUsuario: nombreUsuario,
            password: passwordIngresada,
          );
          
          print('📥 Respuesta API: ok=${result.ok}, error=${result.error}');
          
          if (result.ok && result.data != null) {
            final usuario = result.data!;
            print('✅ Usuario encontrado en API: ${usuario.nombreUsuario}');
            
            // ✅ Guardar en Hive
            await box.put('usuario_uid', usuario.uid);
            await box.put('usuario_actual', usuario.nombreUsuario);
            await box.put('usuario_nombre', usuario.nombre);
            await box.put('usuario_password', passwordIngresada);
            await box.put('usuario_edad', usuario.edad?.toString() ?? 'No especificada');
            await box.put('usuario_ciudad', usuario.ciudad ?? 'No especificada');
            await box.put('login_exitoso', true);
            
            // ✅ Guardar en AuthService
            await _authService.login(
              nombreUsuario: nombreUsuario,
              password: passwordIngresada,
            );
            
            print('✅ Usuario guardado en Hive y AuthService');
            _irAlMenu();
            return;
          } else {
            setState(() {
              _errorMessage = result.error ?? 'Usuario o contraseña incorrectos';
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          print('⚠️ Error buscando por nombre: $e');
          setState(() {
            _errorMessage = 'Error al conectar con el servidor';
            _isLoading = false;
          });
          return;
        }
      } else {
        // ❌ Sin internet y no está en Hive
        setState(() {
          _errorMessage = 'Sin conexión a internet. Verifica tu conexión.';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      print('❌ Error en login: $e');
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