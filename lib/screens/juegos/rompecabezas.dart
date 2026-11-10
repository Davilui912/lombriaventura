import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../config/theme.dart';
import '../../services/logros_service.dart';
import '../../services/monedas_service.dart';
import '../../services/sound_service.dart';

class RompecabezasScreen extends StatefulWidget {
  const RompecabezasScreen({super.key});

  @override
  State<RompecabezasScreen> createState() => _RompecabezasScreenState();
}

class _RompecabezasScreenState extends State<RompecabezasScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _musicaActivada = true;

  int _pasoActual = 0;

  final List<Map<String, String>> _imagenesDisponibles = [
    {'id': 'lombriz', 'nombre': 'La Lombriz', 'asset': 'assets/images/rompecabezas/lombriz.png'},
    {'id': 'composta', 'nombre': 'La Composta', 'asset': 'assets/images/rompecabezas/composta.png'},
    {'id': 'humus', 'nombre': 'El Humus', 'asset': 'assets/images/rompecabezas/humus.png'},
    {'id': 'plantita', 'nombre': 'La Plantita', 'asset': 'assets/images/rompecabezas/plantita.png'},
    {'id': 'lixiviado', 'nombre': 'El Lixiviado', 'asset': 'assets/images/rompecabezas/lixiviado.png'},
    {'id': 'frutas', 'nombre': 'Frutas y Verduras', 'asset': 'assets/images/rompecabezas/frutas.png'},
    {'id': 'lombricompostero', 'nombre': 'El Lombricompostero', 'asset': 'assets/images/rompecabezas/lombricompostero.png'},
    {'id': 'ciclo_vida', 'nombre': 'Ciclo de Vida', 'asset': 'assets/images/rompecabezas/ciclo_vida.png'},
    {'id': 'planeta', 'nombre': 'El Planeta', 'asset': 'assets/images/rompecabezas/planeta.png'},
  ];

  String _imagenSeleccionada = 'assets/images/rompecabezas/lombriz.png';
  int _nivelSeleccionado = 0;
  late List<int> _piezas;
  int? _piezaSeleccionada;
  int _movimientos = 0;
  bool _completado = false;
  bool _monedasOtorgadas = false;

  final List<Map<String, dynamic>> _niveles = [
    {'nombre': 'Fácil', 'tamano': 3, 'emoji': '🟢', 'monedas': 1, 'color': const Color(0xFF58CC71)},
    {'nombre': 'Medio', 'tamano': 4, 'emoji': '🟡', 'monedas': 2, 'color': const Color(0xFFFFC107)},
    {'nombre': 'Difícil', 'tamano': 5, 'emoji': '🔴', 'monedas': 3, 'color': const Color(0xFFE53935)},
  ];

  @override
  void initState() {
    super.initState();
    _iniciarMusicaFondo();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _iniciarMusicaFondo() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // ✅ Ruta de la canción
      await _audioPlayer.play(AssetSource('audio/fondo_rompecabezas.mp3'));
      await _audioPlayer.setVolume(0.3); // Volumen bajo para no ensordecer
    } catch (e) {
      print('Error al cargar la música del rompecabezas: $e');
    }
  }

  void _toggleMusica() {
    setState(() {
      _musicaActivada = !_musicaActivada;
      if (_musicaActivada) {
        _audioPlayer.setVolume(0.3);
        _audioPlayer.resume();
      } else {
        _audioPlayer.setVolume(0);
        _audioPlayer.pause();
      }
    });
  }

  int get _tamano => _niveles[_nivelSeleccionado]['tamano'] as int;
  int get _monedasRecompensa => _niveles[_nivelSeleccionado]['monedas'] as int;
  String get _nombreNivel => _niveles[_nivelSeleccionado]['nombre'] as String;

  void _empezarJuego() {
    final total = _tamano * _tamano;
    _piezas = List.generate(total, (i) => i)..shuffle(Random());
    _piezaSeleccionada = null;
    _movimientos = 0;
    _completado = false;
    _monedasOtorgadas = false;
    _pasoActual = 2;
    setState(() {});
  }

  void _seleccionarPieza(int index) {
    if (_completado) return;
    setState(() {
      if (_piezaSeleccionada == null) {
        _piezaSeleccionada = index;
      } else {
        final temp = _piezas[_piezaSeleccionada!];
        _piezas[_piezaSeleccionada!] = _piezas[index];
        _piezas[index] = temp;
        _piezaSeleccionada = null;
        _movimientos++;
        if (_verificarCompletado()) {
          _completado = true;
          _otorgarRecompensa();
        }
      }
    });
  }

  bool _verificarCompletado() {
    for (int i = 0; i < _piezas.length; i++) {
      if (_piezas[i] != i) return false;
    }
    return true;
  }

  Future<void> _otorgarRecompensa() async {
    if (_monedasOtorgadas) return;
    _monedasOtorgadas = true;
    final monedasService = MonedasService();
    await monedasService.init();
    await monedasService.agregarMonedas(_monedasRecompensa);
    LogrosService().desbloquearInsignia('rompecabezas');
    SoundService.instance.monedasGanadas();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎉 ¡Completaste el rompecabezas! +$_monedasRecompensa monedas 🪙'), backgroundColor: AppTheme.verde),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _pasoActual == 0 ? '🖼️ Elige una imagen' : 
          _pasoActual == 1 ? '🎯 Elige dificultad' : '🧩 Rompecabezas'
        ),
        backgroundColor: AppTheme.verde,
        elevation: 4,
        leading: _pasoActual > 0 && _pasoActual < 2 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _pasoActual--),
            )
          : null,
        actions: [
          IconButton(
            icon: Icon(_musicaActivada ? Icons.volume_up : Icons.volume_off, color: Colors.white),
            onPressed: _toggleMusica,
          ),
          if (_pasoActual == 2)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('Mov: $_movimientos', style: const TextStyle(fontSize: 14)),
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
          child: _pasoActual == 0 
              ? _buildSeleccionImagen()
              : _pasoActual == 1 
                  ? _buildSeleccionDificultad()
                  : _buildJuego(),
        ),
      ),
    );
  }

  Widget _buildSeleccionImagen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('¿Qué imagen quieres armar?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8,
            ),
            itemCount: _imagenesDisponibles.length,
            itemBuilder: (context, index) {
              final img = _imagenesDisponibles[index];
              final seleccionada = _imagenSeleccionada == img['asset'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _imagenSeleccionada = img['asset']!;
                    _pasoActual = 1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: seleccionada ? AppTheme.verde : Colors.grey.shade300, width: seleccionada ? 4 : 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: Image.asset(
                            img['asset']!, width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 50, color: Colors.grey)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(img['nombre']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeleccionDificultad() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(_imagenSeleccionada, width: 120, height: 120, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              const Text('Elige la dificultad', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...List.generate(_niveles.length, (index) {
                final nivel = _niveles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nivel['color'],
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _nivelSeleccionado = index;
                        _empezarJuego();
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(nivel['emoji'], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text('${nivel['nombre']} (${nivel['tamano']}x${nivel['tamano']})', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuego() {
    final screenWidth = MediaQuery.of(context).size.width;
    final tableroSize = (screenWidth - 32).clamp(200.0, 450.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '🧩 $_nombreNivel\n($_tamano x $_tamano)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.verde, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(_imagenSeleccionada, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: SizedBox(
              width: tableroSize,
              height: tableroSize,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _tamano, crossAxisSpacing: 2, mainAxisSpacing: 2,
                ),
                itemCount: _piezas.length,
                itemBuilder: (context, index) => _buildPieza(index),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.touch_app, color: AppTheme.verde, size: 18),
                    const SizedBox(width: 4),
                    Text('Mov: $_movimientos', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.verde, size: 18),
                    const SizedBox(width: 4),
                    Text('Correctas: ${_piezas.where((p) => _piezas[p] == p).length}/${_piezas.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => _pasoActual = 0),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Cambiar imagen', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _empezarJuego,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reiniciar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          if (_completado) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 50)),
                  Text('¡Felicidades!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.verde)),
                  Text('Lo completaste en $_movimientos movimientos', style: const TextStyle(fontSize: 14)),
                  Text('💰 +$_monedasRecompensa monedas', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPieza(int index) {
    final piezaIndex = _piezas[index];
    final fila = piezaIndex ~/ _tamano;
    final columna = piezaIndex % _tamano;
    final estaSeleccionada = _piezaSeleccionada == index;
    final estaEnLugar = piezaIndex == index;

    return GestureDetector(
      onTap: () => _seleccionarPieza(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: estaSeleccionada ? Colors.amber : (estaEnLugar ? AppTheme.verde : Colors.grey.shade300),
            width: estaSeleccionada ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final imagenCompletaAncho = constraints.maxWidth * _tamano;
                  final imagenCompletaAlto = constraints.maxHeight * _tamano;
                  final offsetX = -columna * constraints.maxWidth;
                  final offsetY = -fila * constraints.maxHeight;

                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: offsetX,
                        top: offsetY,
                        width: imagenCompletaAncho,
                        height: imagenCompletaAlto,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            _imagenSeleccionada,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.image)));
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (estaSeleccionada) Container(color: Colors.amber.withValues(alpha: 0.3)),
              if (estaEnLugar && !estaSeleccionada)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppTheme.verde, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}