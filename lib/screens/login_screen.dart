import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'menu_principal.dart';
import 'recuperar_password_screen.dart';
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
   // _crearUsuarioPruebaSiNoExiste();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final box = await Hive.openBox('usuarios');
    final emailActual = box.get('usuario_actual');
    
    if (emailActual != null) {
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

    try {
      final box = await Hive.openBox('usuarios');
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
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
      Map<String, dynamic>? usuarioEncontrado;
      for (var u in usuarios) {
        if (u['email'] == email && u['password'] == password) {
          usuarioEncontrado = u;
          break;
        }
      }

      if (usuarioEncontrado != null) {
        await box.put('usuario_actual', email);
        await box.put('usuario_nombre', usuarioEncontrado['nombre']);
        await box.put('usuario_edad', usuarioEncontrado['edad']);
        await box.put('usuario_ciudad', usuarioEncontrado['ciudad']);
        await box.put('usuario_genero', usuarioEncontrado['genero'] ?? 'Lola');
        await box.put('usuario_fecha_registro', usuarioEncontrado['fechaRegistro'] ?? DateTime.now().toIso8601String());
        
        _irAlMenu();
      } else {
        final emailExiste = usuarios.any((u) => u['email'] == email);
        if (emailExiste) {
          setState(() {
            _errorMessage = '❌ Contraseña incorrecta';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = '❌ Correo no registrado';
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // --- SECCIÓN DEL LOGO Y TÍTULO (SÚPER AJUSTADO) ---
                Image.asset(
                  'assets/images/logo_lombriaventura.png',
                  width: 180, // Lo bajé un pelín a 180 para asegurar compatibilidad en pantallas mini
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bug_report, size: 70, color: AppTheme.verde),
                    );
                  },
                ),
                
                // Este espacio es mínimo para que el texto se pegue directo a la base de la circunferencia
                const SizedBox(height: 2), 
                
                const Text(
                  'Lombriaventura',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24, // Tamaño seguro para todos los celulares
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(offset: Offset(0, 1.5), blurRadius: 3, color: Colors.black26),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 25), // Espacio controlado antes de la tarjeta

                // --- TARJETA DE LOGIN ---
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        
                        // Mensaje de Error
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Input: Correo
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
                        
                        // Input: Contraseña
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
                        
                        // Olvidé mi contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RecuperarPasswordScreen()),
                              );
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Text(
                              '¿Olvidaste tu contraseña?', 
                              style: TextStyle(color: AppTheme.verde, fontSize: 13),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón Ingresar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.verde,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Ingresar', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: _irARegistro,
                            child: const Text('Regístrate', style: TextStyle(color: AppTheme.verde, fontWeight: FontWeight.bold)),
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