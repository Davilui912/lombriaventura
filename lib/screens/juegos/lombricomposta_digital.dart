import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';
import '../../services/sound_service.dart';

class Lombriz {
  double x;
  double y;
  Lombriz({required this.x, required this.y});
}

class Comida {
  double x;
  double y;
  String emoji;
  bool comiendo;
  Comida({required this.x, required this.y, required this.emoji, this.comiendo = false});
}

class LombricompostaDigitalScreen extends StatefulWidget {
  const LombricompostaDigitalScreen({super.key});

  @override
  State<LombricompostaDigitalScreen> createState() => _LombricompostaDigitalScreenState();
}

class _LombricompostaDigitalScreenState extends State<LombricompostaDigitalScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _musicaActivada = true;
  final Random _random = Random();

  // ✅ Estado del juego
  int _humus = 0;
  int _humedad = 50;
  int _materialSeco = 0; // ✅ Cantidad de hojas secas
  int _residuosTotales = 0;
  int _contadorCiclos = 0;

  // ✅ Entidades
  List<Lombriz> _lombrices = [];
  List<Comida> _comidas = [];
  List<Offset> _moscas = [];
  List<Offset> _gotasAgua = []; // Para las gotas al regar
  List<Offset> _hojasSecas = []; // ✅ Para las hojas que caen

  Timer? _gameLoop;

  @override
  void initState() {
    super.initState();
    _iniciarMusicaFondo();
    _iniciarJuego();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _gameLoop?.cancel();
    super.dispose();
  }

  Future<void> _iniciarMusicaFondo() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/fondo_composta.mp3'));
      await _audioPlayer.setVolume(0.3);
    } catch (e) {
      print('Error al cargar música: $e');
    }
  }

  void _toggleMusica() {
    setState(() {
      _musicaActivada = !_musicaActivada;
      _musicaActivada ? _audioPlayer.resume() : _audioPlayer.pause();
    });
  }

  void _iniciarJuego() {
    setState(() {
      _lombrices = [Lombriz(x: 150, y: 150)];
      _comidas = [];
      _moscas = [];
      _gotasAgua = [];
      _hojasSecas = [];
      _humus = 0;
      _humedad = 50;
      _materialSeco = 0;
      _residuosTotales = 0;
      _contadorCiclos = 0;
    });

    _gameLoop = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      _actualizarJuego();
    });
  }

  void _actualizarJuego() {
    setState(() {
      _contadorCiclos++;

      // 1. Mover lombrices hacia la comida
      for (var lombriz in _lombrices) {
        final comidasDisponibles = _comidas.where((c) => !c.comiendo).toList();
        
        if (comidasDisponibles.isNotEmpty) {
          Comida objetivo = comidasDisponibles[0];
          double distanciaMin = double.infinity;
          
          for (var comida in comidasDisponibles) {
            double dist = sqrt(pow(lombriz.x - comida.x, 2) + pow(lombriz.y - comida.y, 2));
            if (dist < distanciaMin) {
              distanciaMin = dist;
              objetivo = comida;
            }
          }

          if (distanciaMin > 25) {
            lombriz.x += (objetivo.x - lombriz.x) * 0.01;
            lombriz.y += (objetivo.y - lombriz.y) * 0.01;
          } else {
            objetivo.comiendo = true;
            
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _comidas.remove(objetivo);
                  _humus = (_humus + 2).clamp(0, 100);
                  _residuosTotales++;
                  SoundService.instance.monedasGanadas();

                  if (_humus >= 30 && _humedad > 40 && _humedad < 80 && _lombrices.length < 5) {
                    _lombrices.add(Lombriz(x: lombriz.x + 20, y: lombriz.y + 20));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🐛 ¡Nació una lombriz bebé!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                });
              }
            });
          }
        }
      }

      // 2. Moscas si hay mal olor (mucho residuo y poco material seco)
      if (_residuosTotales > 5 && _materialSeco < 3) {
        if (_moscas.length < 5) {
          _moscas.add(Offset(
            _random.nextDouble() * 300,
            _random.nextDouble() * 300,
          ));
        }
      } else {
        _moscas.clear();
      }

      // 3. Humedad baja lentamente
      if (_contadorCiclos % 20 == 0 && _humedad > 0) {
        _humedad--;
      }

      // 4. Limpiar animaciones
      if (_gotasAgua.isNotEmpty && _contadorCiclos % 5 == 0) {
        _gotasAgua.removeAt(0);
      }
      if (_hojasSecas.isNotEmpty && _contadorCiclos % 5 == 0) {
        _hojasSecas.removeAt(0);
      }
    });
  }

  void _anadirrResiduo(String emoji) {
    setState(() {
      _comidas.add(Comida(
        x: _random.nextDouble() * 250 + 20,
        y: _random.nextDouble() * 200 + 20,
        emoji: emoji,
      ));
    });
  }

  void _anadirrMaterialSeco() {
    setState(() {
      _materialSeco++;
      // ✅ El material seco ABSORBE la humedad (la baja)
      _humedad = (_humedad - 10).clamp(0, 100); 
      
      // ✅ Animación de hoja seca cayendo
      _hojasSecas.add(Offset(
        _random.nextDouble() * 300,
        0, // Empieza arriba
      ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🍂 anadirste material seco. ¡La humedad bajó!'),
          backgroundColor: Colors.brown,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _regar() {
    setState(() {
      _humedad = (_humedad + 15).clamp(0, 100);
      _gotasAgua.add(Offset(
        _random.nextDouble() * 300,
        _random.nextDouble() * 100,
      ));
    });
  }

  void _cosecharHumus() {
    if (_humus >= 20) {
      setState(() => _humus = 0);
      MonedasService().agregarMonedas(5);
      SoundService.instance.monedasGanadas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌱 ¡Cosechaste humus! +5 monedas 🪙'),
          backgroundColor: AppTheme.verde,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ El humus aún no está listo (necesitas 20%).'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🪱 Lombricomposta Realista'),
        backgroundColor: AppTheme.verde,
        actions: [
          IconButton(
            icon: Icon(_musicaActivada ? Icons.volume_up : Icons.volume_off, color: Colors.white),
            onPressed: _toggleMusica,
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.brown.shade900, width: 6),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Container(color: Colors.brown.shade400.withValues(alpha: 0.3)),

                        // Comidas
                        for (var comida in _comidas)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            left: comida.x,
                            top: comida.y,
                            child: AnimatedOpacity(
                              opacity: comida.comiendo ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 800),
                              child: AnimatedScale(
                                scale: comida.comiendo ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 800),
                                child: Text(comida.emoji, style: const TextStyle(fontSize: 32)),
                              ),
                            ),
                          ),

                        // Lombrices
                        for (var lombriz in _lombrices)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            left: lombriz.x,
                            top: lombriz.y,
                            child: const Text('🪱', style: TextStyle(fontSize: 36)),
                          ),

                        // Moscas
                        for (var mosca in _moscas)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeInOut,
                            left: mosca.dx,
                            top: mosca.dy,
                            child: const Text('🪰', style: TextStyle(fontSize: 24)),
                          ),

                        // Gotas de agua
                        for (var gota in _gotasAgua)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            left: gota.dx,
                            top: gota.dy,
                            child: const Text('💧', style: TextStyle(fontSize: 24)),
                          ),

                        // ✅ Hojas secas
                        for (var hoja in _hojasSecas)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeIn,
                            left: hoja.dx,
                            top: hoja.dy,
                            child: const Text('🍂', style: TextStyle(fontSize: 24)),
                          ),

                        // Humus visual
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            height: _humus * 2.0,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade900.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('🪱', '${_lombrices.length}'),
                        _buildStat('💧', '$_humedad%'),
                        _buildStat('🌱', '$_humus%'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildBoton('🍎 Fruta', () => _anadirrResiduo('🍎')),
                        _buildBoton('🍌 Cáscara', () => _anadirrResiduo('🍌')),
                        _buildBoton('🍂 Seco', _anadirrMaterialSeco),
                        _buildBoton('💧 Regar', _regar),
                        _buildBoton('🌱 Cosechar', _cosecharHumus),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.verde,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  Widget _buildStat(String emoji, String valor) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}