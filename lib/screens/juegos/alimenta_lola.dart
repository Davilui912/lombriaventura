import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/logros_service.dart';

class AlimentaLolaScreen extends StatefulWidget {
  const AlimentaLolaScreen({super.key});

  @override
  State<AlimentaLolaScreen> createState() => _AlimentaLolaScreenState();
}

class _AlimentaLolaScreenState extends State<AlimentaLolaScreen> {
  int _puntuacion = 0;
  int _vidas = 3;
  bool _jugando = false;
  bool _juegoTerminado = false;
  Timer? _timer;
  Timer? _timerComida;
  int _tiempoRestante = 30;

  // Posición de Lola
  double _lolaX = 0.5;

  // Comida actual
  Map<String, dynamic>? _comidaActual;
  bool _comidaCorrecta = true;
  String _mensaje = '';

  final List<Map<String, dynamic>> _comidasBuenas = [
    {'nombre': 'Cáscara de plátano', 'emoji': '🍌', 'puntos': 10},
    {'nombre': 'Cáscara de manzana', 'emoji': '🍎', 'puntos': 10},
    {'nombre': 'Hojas secas', 'emoji': '🍂', 'puntos': 10},
    {'nombre': 'Cáscara de huevo', 'emoji': '🥚', 'puntos': 15},
    {'nombre': 'Restos de café', 'emoji': '☕', 'puntos': 10},
    {'nombre': 'Cáscara de zanahoria', 'emoji': '🥕', 'puntos': 10},
  ];

  final List<Map<String, dynamic>> _comidasMalas = [
    {'nombre': 'Bolsa de plástico', 'emoji': '🛍️', 'puntos': -5},
    {'nombre': 'Pila', 'emoji': '🔋', 'puntos': -5},
    {'nombre': 'Carne', 'emoji': '🥩', 'puntos': -5},
    {'nombre': 'Queso', 'emoji': '🧀', 'puntos': -5},
  ];

  void _iniciarJuego() {
    setState(() {
      _puntuacion = 0;
      _vidas = 3;
      _jugando = true;
      _juegoTerminado = false;
      _tiempoRestante = 30;
      _mensaje = '¡Alimenta a Lola con comida buena! 🪱';
    });
    _generarComida();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _tiempoRestante--;
        if (_tiempoRestante <= 0) {
          _terminarJuego();
        }
      });
    });
  }

  void _generarComida() {
    _timerComida?.cancel();
    final random = Random();
    // 60% probabilidad de comida buena, 40% mala
    final esBuena = random.nextDouble() < 0.6;

    setState(() {
      if (esBuena) {
        _comidaActual = _comidasBuenas[random.nextInt(_comidasBuenas.length)];
        _comidaCorrecta = true;
      } else {
        _comidaActual = _comidasMalas[random.nextInt(_comidasMalas.length)];
        _comidaCorrecta = false;
      }
      _lolaX = 0.2 + random.nextDouble() * 0.6;
    });

    // Si es comida mala, desaparece sola después de 2 segundos
    if (!_comidaCorrecta) {
      _timerComida = Timer(const Duration(seconds: 2), () {
        if (mounted && _jugando) {
          setState(() {
            _mensaje = '¡Bien! Esquivaste ${_comidaActual?['emoji']} (no es para Lola) 🎉';
          });
          _generarComida();
        }
      });
    }
  }

  void _tocarComida() {
    if (!_jugando || _comidaActual == null) return;

    if (_comidaCorrecta) {
      // ¡Comida buena! Lola come feliz
      setState(() {
        _puntuacion += (_comidaActual?['puntos'] ?? 10) as int;
        _mensaje = '¡Ñam ñam! ${_comidaActual?['emoji']} ¡Gracias! 😋';
      });
      if (_puntuacion >= 30) {
        LogrosService().desbloquearInsignia('alimentador');
        }
      _generarComida();
    } else {
      // ¡Comida mala! Lola se enferma
      setState(() {
        _vidas--;
        _mensaje = '¡NOOO! ${_comidaActual?['emoji']} es MALO para Lola 😢';
        if (_vidas <= 0) {
          _terminarJuego();
          return;
        }
      });
      _generarComida();
    }
  }

  void _terminarJuego() {
    _timer?.cancel();
    _timerComida?.cancel();
    setState(() {
      _jugando = false;
      _juegoTerminado = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerComida?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🪱 Alimenta a Lola'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text('$_vidas', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: AppTheme.amarillo, size: 20),
                  const SizedBox(width: 4),
                  Text('$_puntuacion', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _juegoTerminado ? _buildPantallaFinal() : _buildJuego(),
    );
  }

  Widget _buildJuego() {
    if (!_jugando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🪱', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text(
              '¡Alimenta a Lola!',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 28, color: AppTheme.verde),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Toca la comida BUENA para dársela a Lola.\nNO toques la comida MALA o Lola se enfermará.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.cafe),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _iniciarJuego,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              child: const Text('🎮 ¡Comenzar!', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Fondo de tierra y cielo
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF87CEEB), Color(0xFF8B5E3C)],
            ),
          ),
        ),

        // Timer y mensaje
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppTheme.cafe),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _tiempoRestante / 30,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.verde),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${_tiempoRestante}s', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (_mensaje.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _mensaje.contains('NOOO') ? Colors.red.withValues(alpha: 0.8) : AppTheme.verde.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _mensaje,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Lola y la comida
        Positioned(
          left: _lolaX * MediaQuery.of(context).size.width - 40,
          bottom: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            children: [
              // Comida (arriba de Lola)
              if (_comidaActual != null)
                GestureDetector(
                  onTap: _tocarComida,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _comidaCorrecta ? AppTheme.verde : Colors.red,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_comidaActual!['emoji'], style: const TextStyle(fontSize: 45)),
                        const SizedBox(height: 4),
                        Text(
                          _comidaActual!['nombre'],
                          style: const TextStyle(fontSize: 11, color: AppTheme.cafe),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Lola
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.verde,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🪱', style: TextStyle(fontSize: 40)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPantallaFinal() {
    final ganaste = _vidas > 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ganaste ? '🏆' : '😢', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              ganaste ? '¡Se acabó el tiempo!' : '¡Lola se enfermó!',
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 28, color: AppTheme.verde),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Puntuación final: $_puntuacion ⭐',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              'Vidas restantes: ${'❤️' * _vidas}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _iniciarJuego,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: const Text('🔄 Jugar de nuevo', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}