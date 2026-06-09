import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import 'splash_screen.dart';

class SelectorPersonaje extends StatefulWidget {
  const SelectorPersonaje({super.key});

  @override
  State<SelectorPersonaje> createState() => _SelectorPersonajeState();
}

class _SelectorPersonajeState extends State<SelectorPersonaje> {
  String? _personajeSeleccionado;

  void _seleccionarPersonaje() async {
    if (_personajeSeleccionado != null) {
      // Guardar la selección en Hive
      final box = await Hive.openBox('configuracion');
      await box.put('personaje', _personajeSeleccionado);
      
      // Navegar al splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🪱 Lombriaventura',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '¿Quieres ser Lola o Lalo?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPersonajeCard(
                      nombre: 'Lola',
                      imagen: 'lola_base.png',
                      color: AppTheme.verde,
                      seleccionado: _personajeSeleccionado == 'Lola',
                      onTap: () {
                        setState(() {
                          _personajeSeleccionado = 'Lola';
                        });
                      },
                    ),
                    _buildPersonajeCard(
                      nombre: 'Lalo',
                      imagen: 'lalo_base.png',
                      color: AppTheme.azulCielo,
                      seleccionado: _personajeSeleccionado == 'Lalo',
                      onTap: () {
                        setState(() {
                          _personajeSeleccionado = 'Lalo';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _personajeSeleccionado != null
                      ? _seleccionarPersonaje
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.verde,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Comenzar aventura',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonajeCard({
    required String nombre,
    required String imagen,
    required Color color,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // ✅ Imagen del personaje (en lugar del emoji)
            Image.asset(
              'assets/images/personajes/$imagen',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                // Si no carga la imagen, mostrar un placeholder
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.bug_report, size: 50, color: AppTheme.cafe),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              nombre,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: seleccionado ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}