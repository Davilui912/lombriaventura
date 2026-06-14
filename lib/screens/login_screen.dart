import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import '../models/usuario.dart';
import 'menu_principal.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
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
    final box = await Hive.openBox('usuarios');
    final emailActual = box.get('usuario_actual');
    
    if (emailActual != null) {
      // Hay una sesión activa
      _irAlMenu();
    }
  }

  Future<void> _iniciarSesion() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo');
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

    final box = await Hive.openBox('usuarios');
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    // Buscar usuario por email
    final usuarios = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
    final usuarioEncontrado = usuarios.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => null,
    );

    if (usuarioEncontrado != null) {
      // Guardar sesión actual
      await box.put('usuario_actual', email);
      await box.put('usuario_nombre', usuarioEncontrado['nombre']);
      await box.put('usuario_edad', usuarioEncontrado['edad']);
      await box.put('usuario_ciudad', usuarioEncontrado['ciudad']);
      
      _irAlMenu();
    } else {
      setState(() {
        _errorMessage = 'Correo o contraseña incorrectos';
        _isLoading = false;
      });
    }
  }

  void _irAlMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuPrincipal()),
    );
  }

  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bug_report, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Lombriaventura',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: const Icon(Icons.email, color: AppTheme.verde),
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