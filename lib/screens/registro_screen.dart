import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
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
  final TextEditingController _respuestaSeguridadController = TextEditingController();
  
  String? _genero;
  String? _preguntaSeguridad;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmar = true;
  String? _errorMessage;

  final List<String> _preguntasSeguridad = [
    '¿Cómo se llamaba tu primera mascota?',
    '¿Cuál es el nombre de tu mejor amigo?',
    '¿Qué color te gusta más?',
    '¿Cuál es tu comida favorita?',
    '¿Cómo se llama tu escuela?',
  ];

  Widget _buildGeneroCard(String nombre, IconData icon, bool seleccionado) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _genero = nombre),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: seleccionado ? AppTheme.verde : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: seleccionado ? Colors.white : AppTheme.verde, size: 20),
                const SizedBox(width: 8),
                Text(
                  nombre,
                  style: TextStyle(
                    color: seleccionado ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registrarUsuario() async {
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
    if (_genero == null) {
      setState(() => _errorMessage = 'Elige Lola o Lalo');
      return;
    }
    if (_preguntaSeguridad == null) {
      setState(() => _errorMessage = 'Elige una pregunta de seguridad');
      return;
    }
    if (_respuestaSeguridadController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa la respuesta de seguridad');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final box = await Hive.openBox('usuarios');
      final usuariosRaw = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
      
      // Convertir usuarios existentes
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
      
      final existe = usuarios.any((u) => u['email'] == _emailController.text.trim());
      if (existe) {
        setState(() {
          _errorMessage = 'Este correo ya está registrado';
          _isLoading = false;
        });
        return;
      }

      final nuevoUsuario = {
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'edad': int.tryParse(_edadController.text.trim()) ?? 0,
        'ciudad': _ciudadController.text.trim(),
        'genero': _genero,
        'preguntaSeguridad': _preguntaSeguridad,
        'respuestaSeguridad': _respuestaSeguridadController.text.trim().toLowerCase(),
        'fechaRegistro': DateTime.now().toIso8601String(),
      };
      
      usuarios.add(nuevoUsuario);
      await box.put('lista', usuarios);
      await box.put('usuario_actual', _emailController.text.trim());
      await box.put('usuario_nombre', _nombreController.text.trim());
      await box.put('usuario_edad', _edadController.text.trim());
      await box.put('usuario_ciudad', _ciudadController.text.trim());
      await box.put('usuario_genero', _genero);
      await box.put('usuario_fecha_registro', DateTime.now().toIso8601String());

      setState(() => _isLoading = false);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppTheme.verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                labelText: 'Contraseña (mínimo 4 caracteres)',
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
            const SizedBox(height: 16),
            
            const Text('🪱 Elige tu acompañante', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildGeneroCard('Lola', Icons.female, _genero == 'Lola'),
                const SizedBox(width: 16),
                _buildGeneroCard('Lalo', Icons.male, _genero == 'Lalo'),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('🔐 Pregunta de seguridad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _preguntaSeguridad,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Selecciona una pregunta'),
                ),
                isExpanded: true,
                items: _preguntasSeguridad.map((pregunta) {
                  return DropdownMenuItem(
                    value: pregunta,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(pregunta, overflow: TextOverflow.ellipsis),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _preguntaSeguridad = value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _respuestaSeguridadController,
              decoration: InputDecoration(
                labelText: 'Respuesta',
                prefixIcon: const Icon(Icons.security, color: AppTheme.verde),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText: 'Esta respuesta te ayudará a recuperar tu contraseña',
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