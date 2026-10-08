import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/logros_service.dart';
import '../../services/monedas_service.dart';
import '../../services/sound_service.dart';

class MemoramaScreen extends StatefulWidget {
  const MemoramaScreen({super.key});

  @override
  State<MemoramaScreen> createState() => _MemoramaScreenState();
}

class _MemoramaScreenState extends State<MemoramaScreen> {
  // ✅ Ahora son vidas (solo se restan al fallar)
  static const int _vidasIniciales = 10;

  // ✅ IMÁGENES para las parejas
  final List<Map<String, String>> _parejasBase = [
    {'imagen': 'assets/images/memorama/Lombrices.png', 'nombre': 'Lombrices'},
    {'imagen': 'assets/images/memorama/Compostaje.png', 'nombre': 'Compostaje'},
    {'imagen': 'assets/images/memorama/Humus.png', 'nombre': 'Humus'},
    {'imagen': 'assets/images/memorama/Lixiviado.png', 'nombre': 'Lixiviado'},
    {
      'imagen': 'assets/images/memorama/Lombricultura.png',
      'nombre': 'Lombricultura'
    },
    {
      'imagen': 'assets/images/memorama/Materia_organica.png',
      'nombre': 'Materia organica'
    },
    {
      'imagen': 'assets/images/memorama/Planta_crecimiento.png',
      'nombre': 'Planta en crecimiento'
    },
    {
      'imagen': 'assets/images/memorama/Composteria.png',
      'nombre': 'Composteria'
    },
  ];

  List<Map<String, dynamic>> _cartas = [];
  int? _primeraCarta;
  int? _segundaCarta;
  int _paresEncontrados = 0;
  int _vidasRestantes = _vidasIniciales;
  int _fallos = 0;
  bool _bloqueado = false;
  bool _juegoTerminado = false;
  bool _juegoGanado = false;
  bool _monedasOtorgadas = false;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    List<Map<String, dynamic>> cartas = [];
    for (var pareja in _parejasBase) {
      cartas.add({
        'tipo': 'imagen',
        'contenido': pareja['imagen'],
        'nombre': pareja['nombre'],
        'parejaId': pareja['nombre'],
        'volteada': false,
        'encontrada': false,
      });
      cartas.add({
        'tipo': 'texto',
        'contenido': pareja['nombre'],
        'nombre': pareja['nombre'],
        'parejaId': pareja['nombre'],
        'volteada': false,
        'encontrada': false,
      });
    }

    cartas.shuffle(Random());

    setState(() {
      _cartas = cartas;
      _primeraCarta = null;
      _segundaCarta = null;
      _paresEncontrados = 0;
      _vidasRestantes = _vidasIniciales;
      _fallos = 0;
      _bloqueado = false;
      _juegoTerminado = false;
      _juegoGanado = false;
      _monedasOtorgadas = false;
    });
  }

  Future<void> _otorgarMonedas() async {
    _monedasOtorgadas = true;
    final monedasService = MonedasService();
    await monedasService.init();
    await monedasService.agregarMonedas(25);
    await SoundService.instance.monedasGanadas();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Completaste el memorama! Ganaste 25 monedas 🪙'),
          backgroundColor: AppTheme.verde,
        ),
      );
    }
  }

  void _voltearCarta(int index) {
    if (_bloqueado) return;
    if (_cartas[index]['encontrada']) return;
    if (_primeraCarta == index) return;

    setState(() {
      _cartas[index]['volteada'] = true;
    });

    if (_primeraCarta == null) {
      setState(() {
        _primeraCarta = index;
      });
    } else {
      setState(() {
        _segundaCarta = index;
        _bloqueado = true;
      });
      _verificarPareja();
    }
  }

  void _verificarPareja() {
    final carta1 = _cartas[_primeraCarta!];
    final carta2 = _cartas[_segundaCarta!];

    final sonPareja = carta1['parejaId'] == carta2['parejaId'] &&
        carta1['tipo'] != carta2['tipo'];

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      setState(() {
        if (sonPareja) {
          // ✅ ACIERTO: No se resta vida
          _cartas[_primeraCarta!]['encontrada'] = true;
          _cartas[_segundaCarta!]['encontrada'] = true;
          _paresEncontrados++;

          if (_paresEncontrados >= 4) {
            LogrosService().desbloquearInsignia('memorion');
            SoundService.instance.logroDesbloqueado();
          }

          if (_paresEncontrados == _parejasBase.length) {
            _juegoTerminado = true;
            _juegoGanado = true;
            _otorgarMonedas();
          }
        } else {
          // ❌ FALLO: Se resta una vida
          _cartas[_primeraCarta!]['volteada'] = false;
          _cartas[_segundaCarta!]['volteada'] = false;
          _fallos++;
          _vidasRestantes--;

          // ✅ Si se quedó sin vidas, pierde
          if (_vidasRestantes <= 0 && !_juegoTerminado) {
            _juegoTerminado = true;
            _juegoGanado = false;
          }
        }

        _primeraCarta = null;
        _segundaCarta = null;
        _bloqueado = false;
      });

      if (sonPareja) {
        await SoundService.instance.retoCompletado();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Memorama'),
        backgroundColor: AppTheme.verde,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppTheme.amarillo, size: 18),
                  const SizedBox(width: 4),
                  Text('$_paresEncontrados/${_parejasBase.length}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _juegoTerminado ? _buildPantallaFinal() : _buildJuego(),
        ),
      ),
    );
  }

  Widget _buildJuego() {
    return Column(
      children: [
        // ✅ Cabecera con vidas y pares
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ Vidas (corazones)
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: _vidasRestantes <= 2
                            ? Colors.red
                            : Colors.pink,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Vidas: $_vidasRestantes/$_vidasIniciales',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Fredoka',
                          color: _vidasRestantes <= 2
                              ? Colors.red
                              : AppTheme.cafe,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Pares encontrados
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppTheme.verde, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Pares: $_paresEncontrados/${_parejasBase.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Fredoka',
                          color: AppTheme.verde,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // ✅ Barra de vidas (se vacía conforme pierdes)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _vidasRestantes / _vidasIniciales,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _vidasRestantes <= 2 ? Colors.red : AppTheme.verde,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        // ✅ Tablero de cartas
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _cartas.length,
              itemBuilder: (context, index) {
                return _buildCarta(index);
              },
            ),
          ),
        ),

        // ✅ Botón reiniciar
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: _iniciarJuego,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Reiniciar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verde,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarta(int index) {
    final carta = _cartas[index];
    final volteada = carta['volteada'];
    final encontrada = carta['encontrada'];
    final esImagen = carta['tipo'] == 'imagen';

    return GestureDetector(
      onTap: () => _voltearCarta(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: encontrada
              ? AppTheme.verde.withValues(alpha: 0.3)
              : volteada
                  ? Colors.white
                  : AppTheme.verde,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: encontrada
                ? AppTheme.verde
                : volteada
                    ? AppTheme.cafe.withValues(alpha: 0.3)
                    : AppTheme.verde,
            width: encontrada ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: encontrada
              ? (esImagen
                  ? _buildImagenCarta(carta['contenido'])
                  : _buildTextoCarta(carta['contenido']))
              : (volteada
                  ? (esImagen
                      ? _buildImagenCarta(carta['contenido'])
                      : _buildTextoCarta(carta['contenido']))
                  : const Center(
                      child: Text(
                        '❓',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
        ),
      ),
    );
  }

  Widget _buildImagenCarta(String ruta) {
    return SizedBox.expand(
      child: Image.asset(
        ruta,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              size: 30,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextoCarta(String texto) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.cafe,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPantallaFinal() {
    final estrellas = _juegoGanado
        ? (_vidasRestantes >= 7 ? 3 : (_vidasRestantes >= 4 ? 2 : 1))
        : 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono según resultado
              Text(
                _juegoGanado ? '🎉' : '💔',
                style: const TextStyle(fontSize: 70),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                _juegoGanado ? '¡Ganaste!' : '¡Perdiste!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 28,
                  color: _juegoGanado ? AppTheme.verde : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Mensaje
              Text(
                _juegoGanado
                    ? '¡Encontraste todas las parejas!'
                    : 'Te quedaste sin vidas',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Estrellas (solo si ganó)
              if (_juegoGanado)
                Text('⭐' * estrellas, style: const TextStyle(fontSize: 36)),

              const SizedBox(height: 16),

              // Estadísticas
              _buildEstadistica(
                '🧠 Pares encontrados',
                '$_paresEncontrados/${_parejasBase.length}',
              ),
              _buildEstadistica(
                '❤️ Vidas restantes',
                '$_vidasRestantes/$_vidasIniciales',
              ),
              _buildEstadistica(
                '❌ Fallos',
                '$_fallos',
              ),

              const SizedBox(height: 24),

              // ✅ Botones: Reiniciar y Volver
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _iniciarJuego,
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Reiniciar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.verde,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.exit_to_app,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Volver',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadistica(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.verde.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verde)),
          ),
        ],
      ),
    );
  }
}