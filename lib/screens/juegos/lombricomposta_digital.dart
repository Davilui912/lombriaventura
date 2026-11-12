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
  bool estaComiendo;
  double? targetX;
  double? targetY;
  
  Lombriz({required this.x, required this.y, this.estaComiendo = false});
}

class Comida {
  final int id; 
  double x;
  double y;
  String emoji;
  bool comiendo;
  
  Comida({
    required this.id, 
    required this.x, 
    required this.y, 
    required this.emoji, 
    this.comiendo = false,
  });
}

class Mosca {
  double x;
  double y;
  Mosca({required this.x, required this.y});
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
  
  int _nextComidaId = 0; 
  bool _puedeAnadir = true;

  int _humus = 0;
  int _humedad = 50;
  int _materialSeco = 0;
  int _residuosTotales = 0;
  int _contadorCiclos = 0;
  
  bool _juegoTerminado = false;
  int _moscasAtrapadas = 0;
  static const int _metaMoscas = 5;

  List<Lombriz> _lombrices = [];
  List<Comida> _comidas = [];
  List<Mosca> _moscas = [];
  List<Offset> _gotasAgua = [];
  List<Offset> _hojasSecas = [];

  Timer? _gameLoop;
  Timer? _moscaTimer;

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
    _moscaTimer?.cancel();
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
      _lombrices = [Lombriz(x: 150, y: 150), Lombriz(x: 250, y: 150), ];
      _comidas = [];
      _moscas = [];
      _gotasAgua = [];
      _hojasSecas = [];
      _humus = 0;
      _humedad = 50;
      _materialSeco = 0;
      _residuosTotales = 0;
      _contadorCiclos = 0;
      _juegoTerminado = false;
      _moscasAtrapadas = 0;
      _nextComidaId = 0;
    });

    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted || _juegoTerminado) return;
      _actualizarJuego();
    });

    _moscaTimer?.cancel();
    _moscaTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted || _juegoTerminado) return;
      setState(() {
        for (var mosca in _moscas) {
          mosca.x = _random.nextDouble() * 280 + 20;
          mosca.y = _random.nextDouble() * 250 + 20;
        }
      });
    });
  }

  void _actualizarJuego() {
    bool huboCambio = false;

    for (var lombriz in _lombrices) {
      if (lombriz.estaComiendo) continue;

      final comidasDisponibles = _comidas.where((c) => !c.comiendo).toList();
      
      double? destinoX;
      double? destinoY;
      bool esComida = false;

      if (comidasDisponibles.isNotEmpty) {
        //Hay comida: busca la más cercana
        Comida objetivo = comidasDisponibles[0];
        double distanciaMin = double.infinity;
        
        for (var comida in comidasDisponibles) {
          double dist = sqrt(pow(lombriz.x - comida.x, 2) + pow(lombriz.y - comida.y, 2));
          if (dist < distanciaMin) {
            distanciaMin = dist;
            objetivo = comida;
          }
        }
        destinoX = objetivo.x;
        destinoY = objetivo.y;
        esComida = true;
      } else {
        //No hay comida: camina a un punto aleatorio
        if (lombriz.targetX == null || lombriz.targetY == null) {
          lombriz.targetX = _random.nextDouble() * 280 + 20;
          lombriz.targetY = _random.nextDouble() * 250 + 20;
        }
        destinoX = lombriz.targetX;
        destinoY = lombriz.targetY;
      }

      // Mover hacia el destino
      if (destinoX != null && destinoY != null) {
        double distancia = sqrt(pow(lombriz.x - destinoX, 2) + pow(lombriz.y - destinoY, 2));
        
        // Velocidad: Si es comida, más rápido (0.02). Si es paseo, más lento (0.01)
        double velocidad = esComida ? 0.02 : 0.01; 

        if (distancia > 15) {
          lombriz.x += (destinoX - lombriz.x) * velocidad;
          lombriz.y += (destinoY - lombriz.y) * velocidad;
          huboCambio = true;
        } else {
          // Llegó a su destino
          if (esComida) {
            //Llegó a la comida, ¡se la come!
            lombriz.estaComiendo = true;
            Comida objetivo = comidasDisponibles.firstWhere((c) => c.x == destinoX && c.y == destinoY);
            objetivo.comiendo = true;
            huboCambio = true;
            
            final idObjetivo = objetivo.id;
            
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted && !_juegoTerminado) {
                setState(() {
                  _comidas.removeWhere((c) => c.id == idObjetivo);
                  _humus = (_humus + 2).clamp(0, 100);
                  _residuosTotales++;
                  SoundService.instance.monedasGanadas();
                  
                  lombriz.estaComiendo = false;

                  if (_humus >= 30 && _humedad > 40 && _humedad < 80 && _lombrices.length < 5) {
                    _lombrices.add(Lombriz(x: lombriz.x + 20, y: lombriz.y + 20));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🐛 ¡Nació una lombriz bebé!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              }
            });
          } else {
            //Llegó a su punto de paseo: elige un nuevo destino
            lombriz.targetX = _random.nextDouble() * 280 + 20;
            lombriz.targetY = _random.nextDouble() * 250 + 20;
            huboCambio = true;
          }
        }
      }
    }

    if (huboCambio || _contadorCiclos % 10 == 0) {
      setState(() {
        _contadorCiclos++;

        if (_comidas.length >= 8) {
          if (_moscas.length < 5) {
            _moscas.add(Mosca(
              x: _random.nextDouble() * 280 + 20,
              y: _random.nextDouble() * 250 + 20,
            ));
          }
        } else {
          _moscas.clear();
          _moscasAtrapadas = 0;
        }

        if (_contadorCiclos % 20 == 0 && _humedad > 0) {
          _humedad--;
        }

        if (_humedad >= 100) {
          _terminarJuego('💧 ¡Inundaste el hábitat!', 'Las lombrices se ahogaron.', Icons.water_damage, Colors.blue);
        } else if (_humedad <= 0) {
          _terminarJuego('☀️ ¡Secaste el hábitat!', 'Las lombrices se deshidrataron.', Icons.wb_sunny, Colors.orange);
        }

        if (_gotasAgua.isNotEmpty && _contadorCiclos % 5 == 0) _gotasAgua.removeAt(0);
        if (_hojasSecas.isNotEmpty && _contadorCiclos % 5 == 0) _hojasSecas.removeAt(0);
      });
    }
  }

  void _terminarJuego(String titulo, String mensaje, IconData icono, Color color) {
    _gameLoop?.cancel();
    _moscaTimer?.cancel();
    setState(() {
      _juegoTerminado = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 60, color: color),
            const SizedBox(height: 10),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Humus alcanzado: $_humus%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _iniciarJuego();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde),
              child: const Text('🔄 Intentar de nuevo', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Salir al menú'),
            ),
          ),
        ],
      ),
    );
  }

  void _atraparMosca(int index) {
    setState(() {
      _moscas.removeAt(index);
      _moscasAtrapadas++;
      SoundService.instance.moscaAplastada();

      if (_moscasAtrapadas >= _metaMoscas || _moscas.isEmpty) {
        _moscas.clear();
        _moscasAtrapadas = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🪰 ¡Atrapaste todas las moscas!'),
            backgroundColor: AppTheme.verde,
          ),
        );
      }
    });
  }

  // Aquí es donde se agrega el ID
  void _anadirResiduo(String emoji) {
    if (_juegoTerminado || !_puedeAnadir) return;
    
    _puedeAnadir = false;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _puedeAnadir = true;
    });

    setState(() {
      _comidas.add(Comida(
        id: _nextComidaId++, // ✅ ¡Aquí está la línea que faltaba!
        x: _random.nextDouble() * 250 + 20,
        y: _random.nextDouble() * 200 + 20,
        emoji: emoji,
      ));
    });
  }

  void _anadirMaterialSeco() {
    if (_juegoTerminado) return;
    setState(() {
      _materialSeco++;
      _humedad = (_humedad - 5).clamp(0, 100); 
      _hojasSecas.add(Offset(_random.nextDouble() * 300, 0));
    });
  }

  void _regar() {
    if (_juegoTerminado) return;
    setState(() {
      _humedad = (_humedad + 15).clamp(0, 100);
      _gotasAgua.add(Offset(_random.nextDouble() * 300, _random.nextDouble() * 100));
    });
  }

  void _cosecharHumus() {
    if (_juegoTerminado) return;
    if (_humus >= 20) {
      setState(() => _humus = 0);
      MonedasService().agregarMonedas(5);
      SoundService.instance.monedasGanadas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌱 ¡Cosechaste humus! +5 monedas 🪙'), backgroundColor: AppTheme.verde),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ El humus aún no está listo (necesitas 20%).'), backgroundColor: Colors.blue),
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
          image: DecorationImage(image: AssetImage('assets/images/fondo.png'), fit: BoxFit.cover),
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Container(color: Colors.brown.shade400.withValues(alpha: 0.3)),

                        //Comida estática (sin saltos)
                        for (var comida in _comidas)
                          Positioned(
                            key: ValueKey(comida.id),
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

                        for (var lombriz in _lombrices)
                          Positioned(
                            left: lombriz.x,
                            top: lombriz.y,
                            child: const Text('🪱', style: TextStyle(fontSize: 36)),
                          ),

                        for (int i = 0; i < _moscas.length; i++)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: _moscas[i].x,
                            top: _moscas[i].y,
                            child: GestureDetector(
                              onTap: () => _atraparMosca(i),
                              child: const Text('🪰', style: TextStyle(fontSize: 30)),
                            ),
                          ),

                        for (var gota in _gotasAgua)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            left: gota.dx,
                            top: gota.dy,
                            child: const Text('💧', style: TextStyle(fontSize: 24)),
                          ),

                        for (var hoja in _hojasSecas)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeIn,
                            left: hoja.dx,
                            top: hoja.dy,
                            child: const Text('🍂', style: TextStyle(fontSize: 24)),
                          ),

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
                    if (_moscas.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '🪰 Atrapa las moscas: $_moscasAtrapadas / $_metaMoscas',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
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
                        _buildBoton('🍎 Fruta', () => _anadirResiduo('🍎')),
                        _buildBoton('🍌 Cáscara', () => _anadirResiduo('🍌')),
                        _buildBoton('🍂 Seco', _anadirMaterialSeco),
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