import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'login_screen.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _respuestaController = TextEditingController();
  final TextEditingController _nuevaPasswordController = TextEditingController();
  
  int _step = 1;
  String? _preguntaSeguridad;
  String? _emailUsuario;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _respuestaController.dispose();
    _nuevaPasswordController.dispose();
    super.dispose();
  }

    Future<void> _verificarEmail() async {
        final email = _emailController.text.trim();
        if (email.isEmpty) {
            setState(() => _errorMessage = 'Ingresa tu correo');
            return;
        }

        setState(() {
            _isLoading = true;
            _errorMessage = null;
        });

        try {
            final box = await Hive.openBox('usuarios');
            final usuariosRaw = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
            
            // Convertir correctamente los datos
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
            
            // Buscar usuario - forma correcta sin orElse: null
            Map<String, dynamic>? usuario;
            for (var u in usuarios) {
            if (u['email'] == email) {
                usuario = u;
                break;
            }
            }

            if (usuario != null) {
            _emailUsuario = email;
            _preguntaSeguridad = usuario['preguntaSeguridad'] ?? '¿Cuál es tu color favorito?';
            setState(() {
                _step = 2;
                _isLoading = false;
            });
            } else {
            setState(() {
                _errorMessage = 'No existe una cuenta con este correo';
                _isLoading = false;
            });
            }
        } catch (e) {
            setState(() {
            _errorMessage = 'Error al verificar. Intenta de nuevo.';
            _isLoading = false;
            });
        }
    }

    Future<void> _verificarRespuesta() async {
        final respuesta = _respuestaController.text.trim();
        if (respuesta.isEmpty) {
            setState(() => _errorMessage = 'Ingresa tu respuesta de seguridad');
            return;
        }

        setState(() {
            _isLoading = true;
            _errorMessage = null;
        });

        try {
            final box = await Hive.openBox('usuarios');
            final usuariosRaw = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
            
            // Convertir correctamente los datos
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
            
            // Buscar usuario - forma correcta sin orElse: null
            Map<String, dynamic>? usuario;
            for (var u in usuarios) {
            if (u['email'] == _emailUsuario) {
                usuario = u;
                break;
            }
            }

            if (usuario != null) {
            final respuestaCorrecta = usuario['respuestaSeguridad'] ?? '';
            if (respuesta.toLowerCase() == respuestaCorrecta.toLowerCase()) {
                setState(() {
                _step = 3;
                _isLoading = false;
                });
            } else {
                setState(() {
                _errorMessage = 'Respuesta incorrecta';
                _isLoading = false;
                });
            }
            } else {
            setState(() {
                _errorMessage = 'Usuario no encontrado';
                _isLoading = false;
            });
            }
        } catch (e) {
            setState(() {
            _errorMessage = 'Error al verificar respuesta';
            _isLoading = false;
            });
        }
    }

    Future<void> _cambiarPassword() async {
        final nuevaPassword = _nuevaPasswordController.text.trim();
        if (nuevaPassword.length < 4) {
            setState(() => _errorMessage = 'La contraseña debe tener al menos 4 caracteres');
            return;
        }

        setState(() {
            _isLoading = true;
            _errorMessage = null;
        });

        try {
            final box = await Hive.openBox('usuarios');
            final usuariosRaw = box.get('lista', defaultValue: <Map<String, dynamic>>[]);
            
            // Convertir correctamente los datos
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
            
            int index = -1;
            for (int i = 0; i < usuarios.length; i++) {
            if (usuarios[i]['email'] == _emailUsuario) {
                index = i;
                break;
            }
            }
            
            if (index != -1) {
            usuarios[index]['password'] = nuevaPassword;
            
            // Guardar de vuelta
            await box.put('lista', usuarios);
            
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('✅ Contraseña cambiada exitosamente'),
                    backgroundColor: AppTheme.verde,
                ),
                );
                
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
            }
            } else {
            setState(() {
                _errorMessage = 'Error: No se encontró el usuario';
                _isLoading = false;
            });
            }
        } catch (e) {
            setState(() {
            _errorMessage = 'Error al cambiar la contraseña: $e';
            _isLoading = false;
            });
        }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: AppTheme.verde,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_step == 1) ...[
              const Text(
                '📧 Ingresa tu correo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Te haremos una pregunta de seguridad', style: TextStyle(color: Colors.grey)),
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email, color: AppTheme.verde),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verificarEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.verde,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Continuar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
            
            if (_step == 2) ...[
              const Text(
                '🔐 Pregunta de seguridad',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_preguntaSeguridad ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                controller: _respuestaController,
                decoration: InputDecoration(
                  labelText: 'Tu respuesta',
                  prefixIcon: const Icon(Icons.security, color: AppTheme.verde),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verificarRespuesta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.verde,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Verificar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
            
            if (_step == 3) ...[
              const Text(
                '🔑 Nueva contraseña',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Crea una nueva contraseña para tu cuenta', style: TextStyle(color: Colors.grey)),
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
                controller: _nuevaPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña (mínimo 4 caracteres)',
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
                  onPressed: _isLoading ? null : _cambiarPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.verde,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Cambiar contraseña', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}