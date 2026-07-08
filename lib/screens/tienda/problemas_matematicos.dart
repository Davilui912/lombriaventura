import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';

class ProblemasMatematicosScreen extends StatefulWidget {
  const ProblemasMatematicosScreen({super.key});

  @override
  State<ProblemasMatematicosScreen> createState() => _ProblemasMatematicosScreenState();
}

class _ProblemasMatematicosScreenState extends State<ProblemasMatematicosScreen> {
  final MonedasService _monedasService = MonedasService();
  
  int _puntuacion = 0;
  int _preguntaActual = 0;
  int _respuestaCorrecta = 0;
  int _monedasGanadas = 0;
  bool _juegoTerminado = false;
  String _mensaje = '';
  
  final List<Map<String, dynamic>> _problemas = [
    {
      'pregunta': 'Si vendes 3 bolsitas de humus a \$10 cada una, ¿cuánto ganaste?',
      'opciones': [20, 30, 40, 50],
      'respuesta': 30,
    },
    {
      'pregunta': 'Tienes 15 lombrices y vendes 7, ¿cuántas te quedan?',
      'opciones': [5, 7, 8, 10],
      'respuesta': 8,
    },
    {
      'pregunta': 'Cada atomizador cuesta \$25. ¿Cuánto cuestan 2 atomizadores?',
      'opciones': [40, 45, 50, 55],
      'respuesta': 50,
    },
    {
      'pregunta': 'Si ganas 5 monedas por día, ¿cuántas ganas en 7 días?',
      'opciones': [25, 30, 35, 40],
      'respuesta': 35,
    },
    {
      'pregunta': 'Tienes 100 monedas y gastas 45 en accesorios, ¿cuántas te quedan?',
      'opciones': [45, 50, 55, 60],
      'respuesta': 55,
    },
    {
      'pregunta': 'Si vendes 4 atomizadores a \$25 cada uno, ¿cuánto ganaste?',
      'opciones': [80, 90, 100, 110],
      'respuesta': 100,
    },
    {
      'pregunta': 'Cada bolsita de humus pesa 2 puños. ¿Cuántos puños son 5 bolsitas?',
      'opciones': [8, 9, 10, 12],
      'respuesta': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _monedasService.init();
    _generarPregunta();
  }

  void _generarPregunta() {
    if (_preguntaActual >= _problemas.length) {
      _terminarJuego();
      return;
    }
    
    final problema = _problemas[_preguntaActual];
    setState(() {
      _respuestaCorrecta = problema['respuesta'];
      _mensaje = '';
    });
  }

  void _responder(int seleccion) {
    if (_juegoTerminado) return;
    
    final problema = _problemas[_preguntaActual];
    if (seleccion == _respuestaCorrecta) {
      setState(() {
        _puntuacion += 10;
        _monedasGanadas += 5;
        _mensaje = '✅ ¡Correcto! +5 monedas 🪙';
      });
    } else {
      setState(() {
        _mensaje = '❌ Incorrecto. La respuesta era $_respuestaCorrecta';
      });
    }
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _preguntaActual++;
          _generarPregunta();
        });
      }
    });
  }

  void _terminarJuego() {
    setState(() {
      _juegoTerminado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧮 Problemas matemáticos'),
        backgroundColor: Colors.orange,
      ),
      body: _juegoTerminado ? _buildPantallaFinal() : _buildJuego(),
    );
  }

  Widget _buildJuego() {
    if (_preguntaActual >= _problemas.length) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final problema = _problemas[_preguntaActual];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Puntuación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta ${_preguntaActual + 1}/${_problemas.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('$_puntuacion', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Pregunta
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              problema['pregunta'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          if (_mensaje.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _mensaje.contains('✅') 
                    ? AppTheme.verde.withValues(alpha: 0.1) 
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mensaje.contains('✅') ? AppTheme.verde : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const SizedBox(height: 30),
          
          // Opciones
          ...problema['opciones'].map<Widget>((opcion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _mensaje.isEmpty ? () => _responder(opcion) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.negro,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    '$opcion',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPantallaFinal() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              '¡Terminaste los problemas!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.verde,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Puntuación: $_puntuacion ⭐',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              'Monedas ganadas: +$_monedasGanadas 🪙',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _puntuacion = 0;
                  _preguntaActual = 0;
                  _monedasGanadas = 0;
                  _juegoTerminado = false;
                  _mensaje = '';
                  _generarPregunta();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.verde,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('🔄 Jugar de nuevo', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}