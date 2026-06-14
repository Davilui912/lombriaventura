import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import '../models/usuario.dart';
import 'login_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmar = true;
  String? _errorMessage;

  Future<void> _registrarUsuario() async {
    // Validaciones
    if (_nombreController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu nombre');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo');
      return;
    }
    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Correo inválido');
      return;
    }
    if (_passwordController.text.length < 4) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 4 caracteres');
      return;
    }
    if (_passwordController.text != _confirmarController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }
    if (_edadController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu edad');
      return;
    }
    if (_ciudadController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu ciudad');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final box = await Hive.openBox('usuarios');
    final usuarios = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
    
    // Verificar si el correo ya existe
    final existe = usuarios.any((u) => u['email'] == _emailController.text.trim());
    if (existe) {
      setState(() {
        _errorMessage = 'Este correo ya está registrado';
        _isLoading = false;
      });
      return;
    }

    // Crear nuevo usuario
    final nuevoUsuario = {
      'nombre': _nombreController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'edad': int.tryParse(_edadController.text.trim()) ?? 0,
      'ciudad': _ciudadController.text.trim(),
      'fechaRegistro': DateTime.now().toIso8601String(),
    };
    
    usuarios.add(nuevoUsuario);
    await box.put('lista', usuarios);

    // Iniciar sesión automáticamente
    await box.put('usuario_actual', _emailController.text.trim());
    await box.put('usuario_nombre', _nombreController.text.trim());
    await box.put('usuario_edad', _edadController.text.trim());
    await box.put('usuario_ciudad', _ciudadController.text.trim());

    setState(() => _isLoading = false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppTheme.verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Registro',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completa tus datos para comenzar',
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
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person, color: AppTheme.verde),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            const SizedBox(height: 16),
            
            TextField(
              controller: _confirmarController,
              obscureText: _obscureConfirmar,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.verde),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmar ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _edadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edad',
                prefixIcon: const Icon(Icons.cake, color: AppTheme.verde),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _ciudadController,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: const Icon(Icons.location_city, color: AppTheme.verde),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Registrarse', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿Ya tienes cuenta?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Iniciar sesión', style: TextStyle(color: AppTheme.verde)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}