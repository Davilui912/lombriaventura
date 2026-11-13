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
  
  double _tableroAncho = 300;
  double _tableroAlto = 300;
  
  int _nextComidaId = 0; 
  bool _puedeAnadir = true;

  int _humus = 0;
  int _lixiviado = 0;
  int _humedad = 50;
  int _materialSeco = 0;
  int _residuosTotales = 0;
  int _contadorCiclos = 0;
  
  int _humusTotal = 0;
  int _lixiviadoTotal = 0;
  
  bool _juegoTerminado = false;
  int _moscasAtrapadas = 0;
  static const int _metaMoscas = 15; // Ahora son 15 moscas para el brote

  //NUEVO: Control de moscas generadas
  int _moscasGeneradas = 0;
  static const int _maxMoscas = 15;

  // Temporizador de peligro por moscas
  Timer? _peligroTimer;
  int _segundosPeligro = 30;
  bool _enPeligro = false;

  List<Lombriz> _lombrices = [];
  List<Comida> _comidas = [];
  List<Mosca> _moscas = [];
  List<Offset> _gotasAgua = [];
  List<Offset> _hojasSecas = [];
  List<Offset> _hojasEnHumus = [];

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
    _peligroTimer?.cancel();
    super.dispose();
  }

  Future<void> _iniciarMusicaFondo() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/California.mp3'));
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

  Offset _posicionAleatoria() {
    final x = _random.nextDouble() * (_tableroAncho - 60) + 30;
    final y = _random.nextDouble() * (_tableroAlto - 60) + 30;
    return Offset(x, y);
  }

  void _iniciarJuego() {
    _peligroTimer?.cancel();
    setState(() {
      _lombrices = [
        Lombriz(x: _tableroAncho * 0.3, y: _tableroAlto * 0.3),
        Lombriz(x: _tableroAncho * 0.6, y: _tableroAlto * 0.3),
      ];
      _comidas = [];
      _moscas = [];
      _gotasAgua = [];
      _hojasSecas = [];
      _hojasEnHumus = [];
      _humus = 0;
      _lixiviado = 0;
      _humedad = 50;
      _materialSeco = 0;
      _residuosTotales = 0;
      _contadorCiclos = 0;
      _humusTotal = 0;
      _lixiviadoTotal = 0;
      _juegoTerminado = false;
      _moscasAtrapadas = 0;
      _moscasGeneradas = 0; //Reiniciar contador
      _nextComidaId = 0;
      _enPeligro = false;
      _segundosPeligro = 30;
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
          final pos = _posicionAleatoria();
          mosca.x = pos.dx;
          mosca.y = pos.dy;
        }
      });
    });
  }

  void _iniciarPeligro() {
    if (_enPeligro) return;
    _enPeligro = true;
    _segundosPeligro = 30;

    _peligroTimer?.cancel();
    _peligroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _juegoTerminado) {
        timer.cancel();
        return;
      }

      setState(() {
        _segundosPeligro--;

        if (_segundosPeligro <= 0) {
          if (_lombrices.isNotEmpty) {
            _lombrices.removeLast();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('💀 ¡Una lombriz murió por las moscas!'),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (_lombrices.isEmpty) {
            _terminarJuego('☠️ ¡Perdiste todas tus lombrices!', 'Las moscas acabaron con ellas.', Icons.dangerous, Colors.red);
            timer.cancel();
            return;
          }

          _segundosPeligro = 30;
        }
      });
    });
  }

  void _detenerPeligro() {
    if (!_enPeligro) return;
    _peligroTimer?.cancel();
    setState(() {
      _enPeligro = false;
      _segundosPeligro = 30;
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
        if (lombriz.targetX == null || lombriz.targetY == null) {
          final pos = _posicionAleatoria();
          lombriz.targetX = pos.dx;
          lombriz.targetY = pos.dy;
        }
        destinoX = lombriz.targetX;
        destinoY = lombriz.targetY;
      }

      if (destinoX != null && destinoY != null) {
        double distancia = sqrt(pow(lombriz.x - destinoX, 2) + pow(lombriz.y - destinoY, 2));
        double velocidad = esComida ? 0.02 : 0.01; 

        if (distancia > 15) {
          lombriz.x += (destinoX - lombriz.x) * velocidad;
          lombriz.y += (destinoY - lombriz.y) * velocidad;
          huboCambio = true;
        } else {
          if (esComida) {
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
                  
                  if (_humus % 5 == 0) {
                    int cantidadHojas = 8 + _random.nextInt(5);
                    for (int i = 0; i < cantidadHojas; i++) {
                      final pos = _posicionAleatoria();
                      _hojasEnHumus.add(Offset(pos.dx, _random.nextDouble() * 180 + 10));
                    }
                  }
                  
                  lombriz.estaComiendo = false;

                  if (_humus >= 30 && _humedad > 40 && _humedad < 80 && _lombrices.length < 5) {
                    _lombrices.add(Lombriz(x: lombriz.x + 20, y: lombriz.y + 20));
                  }
                });
              }
            });
          } else {
            final pos = _posicionAleatoria();
            lombriz.targetX = pos.dx;
            lombriz.targetY = pos.dy;
            huboCambio = true;
          }
        }
      }
    }

    if (huboCambio || _contadorCiclos % 10 == 0) {
      setState(() {
        _contadorCiclos++;

        if (_humedad > 60 && _humus > 20 && _contadorCiclos % 20 == 0) {
          _lixiviado = (_lixiviado + 1).clamp(0, 100);
        }

        // LÓGICA DE MOSCAS MEJORADA
        // Solo generamos moscas si hay mucha comida Y no hemos llegado al límite de 15
        if (_comidas.length >= 8) {
          if (_moscasGeneradas < _maxMoscas && _moscas.length < 5) {
            final pos = _posicionAleatoria();
            _moscas.add(Mosca(x: pos.dx, y: pos.dy));
            _moscasGeneradas++; // Aumentar contador de generadas
          }
        } else {
          // Si se limpia la comida, las moscas se van y el contador se reinicia
          _moscas.clear();
          _moscasAtrapadas = 0;
          _moscasGeneradas = 0; 
        }

        //GESTIÓN DEL PELIGRO
        if (_moscas.isNotEmpty) {
          _iniciarPeligro(); 
        } else {
          _detenerPeligro(); 
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
    _peligroTimer?.cancel();
    setState(() {
      _juegoTerminado = true;
      _enPeligro = false;
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
            Text('Lixiviado: $_lixiviado%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
            const SizedBox(height: 10),
            Text('Total acumulado: $_humusTotal% humus y $_lixiviadoTotal% lixiviado', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  // Atrapar mosca (sin mensajes, solo contador)
  void _atraparMosca(int index) {
    setState(() {
      _moscas.removeAt(index);
      _moscasAtrapadas++;
      SoundService.instance.moscaAplastada();

      // Si ya atrapaste 15 o no quedan moscas, se detiene el peligro
      if (_moscasAtrapadas >= _maxMoscas || _moscas.isEmpty) {
        _moscas.clear();
        _moscasAtrapadas = 0;
        _detenerPeligro();
      }
    });
  }

  void _anadirResiduo(String emoji) {
    if (_juegoTerminado || !_puedeAnadir) return;
    
    _puedeAnadir = false;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _puedeAnadir = true;
    });

    final pos = _posicionAleatoria();
    
    setState(() {
      _comidas.add(Comida(
        id: _nextComidaId++,
        x: pos.dx,
        y: pos.dy,
        emoji: emoji,
      ));
    });
  }

  void _anadirMaterialSeco() {
    if (_juegoTerminado) return;
    setState(() {
      _materialSeco++;
      _humedad = (_humedad - 5).clamp(0, 100); 
      _hojasSecas.add(Offset(_random.nextDouble() * _tableroAncho, 0));
    });
  }

  void _regar() {
    if (_juegoTerminado) return;
    setState(() {
      _humedad = (_humedad + 3).clamp(0, 100);
      final pos = _posicionAleatoria();
      _gotasAgua.add(Offset(pos.dx, _random.nextDouble() * 100));
    });
  }

  void _cosecharHumus() {
    if (_juegoTerminado) return;
    if (_humus >= 20) {
      setState(() {
        _humusTotal += _humus;
        _humus = 0;
        _hojasEnHumus.clear();
      });
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

  void _juntarLixiviado() {
    if (_juegoTerminado) return;
    if (_lixiviado >= 20) {
      setState(() {
        _lixiviadoTotal += _lixiviado;
        _lixiviado = 0;
      });
      MonedasService().agregarMonedas(3); 
      SoundService.instance.monedasGanadas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🟤 ¡Juntaste lixiviado! +3 monedas 🪙'), backgroundColor: Colors.brown),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ El lixiviado aún no está listo (necesitas 20%).'), backgroundColor: Colors.blue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🪱 Lombricomposta'),
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
              // ALERTA DE PELIGRO POR MOSCAS
              if (_enPeligro)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.red.withValues(alpha: 0.8),
                  child: Text(
                    '⚠️ ¡Moscas atacando! ($_moscasAtrapadas/$_maxMoscas) - Lombriz en peligro: $_segundosPeligro s',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.brown.shade900, width: 6),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _tableroAncho = constraints.maxWidth;
                        _tableroAlto = constraints.maxHeight;

                        final double alturaTotal = constraints.maxHeight;
                        final double alturaLixiviado = alturaTotal * 0.25; 
                        final double alturaHumus = alturaTotal * 0.75;     

                        return Stack(
                          children: [
                            Container(color: Colors.brown.shade400.withValues(alpha: 0.3)),

                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 1500),
                                height: (alturaLixiviado * (_lixiviado / 100)).clamp(0, alturaLixiviado),
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade900.withValues(alpha: 0.95),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: alturaLixiviado,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 1000),
                                height: (alturaHumus * (_humus / 100)).clamp(0, alturaHumus),
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade800.withValues(alpha: 0.85),
                                ),
                                child: Stack(
                                  children: [
                                    for (var hoja in _hojasEnHumus)
                                      Positioned(
                                        left: hoja.dx.clamp(0, constraints.maxWidth - 25),
                                        top: hoja.dy.clamp(0, (alturaHumus * (_humus / 100)).clamp(0, alturaHumus) - 25),
                                        child: const Text('🍂', style: TextStyle(fontSize: 22)),
                                      ),
                                  ],
                                ),
                              ),
                            ),

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
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
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
                        _buildStat('🪱', '${_lombrices.length}', isSmallScreen),
                        _buildStat('💧', '$_humedad%', isSmallScreen),
                        _buildStat('🌱', '$_humus%', isSmallScreen),
                        _buildStat('🟤', '$_lixiviado%', isSmallScreen), 
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: isSmallScreen ? 4 : 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total: 🌱 $_humusTotal  |  🟤 $_lixiviadoTotal',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 12),
                    Wrap(
                      spacing: isSmallScreen ? 6 : 10,
                      runSpacing: isSmallScreen ? 6 : 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildBoton('🍎 Fruta', () => _anadirResiduo('🍎'), isSmallScreen),
                        _buildBoton('🍌 Cáscara', () => _anadirResiduo('🍌'), isSmallScreen),
                        _buildBoton('🍂 Seco', _anadirMaterialSeco, isSmallScreen),
                        _buildBoton('💧 Regar', _regar, isSmallScreen),
                        _buildBoton('🌱 Humus', _cosecharHumus, isSmallScreen), 
                        _buildBoton('🟤 Lixiviado', _juntarLixiviado, isSmallScreen), 
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

  Widget _buildBoton(String label, VoidCallback onPressed, bool isSmallScreen) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.verde,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 10, 
          vertical: isSmallScreen ? 6 : 8,
        ),
      ),
      child: Text(
        label, 
        style: TextStyle(
          fontSize: isSmallScreen ? 10 : 12, 
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStat(String emoji, String valor, bool isSmallScreen) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
        Text(
          valor, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ],
    );
  }
}