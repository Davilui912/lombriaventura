import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/logros_service.dart';
import '../../services/monedas_service.dart';
import '../../services/sound_service.dart';

class ClasificaResiduosScreen extends StatefulWidget {
  const ClasificaResiduosScreen({super.key});

  @override
  State<ClasificaResiduosScreen> createState() =>
      _ClasificaResiduosScreenState();
}

class _ClasificaResiduosScreenState extends State<ClasificaResiduosScreen> {
  // ✅ Meta de aciertos para ganar
  static const int _metaAciertos = 15;
  // ✅ Tiempo límite en segundos
  static const int _tiempoLimite = 60;

  int _aciertos = 0;
  int _errores = 0;
  int _ronda = 0;
  int _segundosRestantes = _tiempoLimite;
  bool _juegoTerminado = false;
  bool _juegoGanado = false;
  String _mensaje = 'Arrastra cada residuo al contenedor correcto';
  bool _monedasOtorgadas = false;
  bool _timerActivo = false;

  // Lista de residuos para clasificar
  final List<Map<String, dynamic>> _residuos = [
    {'nombre': 'Cáscara de plátano', 'emoji': '🍌', 'correcto': true},
    {'nombre': 'Botella de plástico', 'emoji': '🧴', 'correcto': false},
    {'nombre': 'Cáscara de huevo', 'emoji': '🥚', 'correcto': true},
    {'nombre': 'Lata de aluminio', 'emoji': '🥫', 'correcto': false},
    {'nombre': 'Restos de café', 'emoji': '☕', 'correcto': true},
    {'nombre': 'Bolsa de plástico', 'emoji': '🛍️', 'correcto': false},
    {'nombre': 'Hojas secas', 'emoji': '🍂', 'correcto': true},
    {'nombre': 'Pila/batería', 'emoji': '🔋', 'correcto': false},
    {'nombre': 'Cáscara de manzana', 'emoji': '🍎', 'correcto': true},
    {'nombre': 'Vidrio roto', 'emoji': '🔷', 'correcto': false},
    {'nombre': 'Restos de verduras', 'emoji': '🥬', 'correcto': true},
    {'nombre': 'Papel de aluminio', 'emoji': '📄', 'correcto': false},
  ];

  List<Map<String, dynamic>> _residuosPendientes = [];

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  @override
  void dispose() {
    _timerActivo = false;
    super.dispose();
  }

  void _iniciarJuego() {
    setState(() {
      _aciertos = 0;
      _errores = 0;
      _ronda = 0;
      _segundosRestantes = _tiempoLimite;
      _juegoTerminado = false;
      _juegoGanado = false;
      _monedasOtorgadas = false;
      _timerActivo = true;
      _mensaje = '¡Clasifica los residuos! ♻️';
    });
    _iniciarRonda();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_timerActivo || _juegoTerminado) return;

      setState(() {
        _segundosRestantes--;
      });

      if (_segundosRestantes <= 0) {
        _terminarJuego(false);
      } else {
        _iniciarTimer();
      }
    });
  }

  void _iniciarRonda() {
    setState(() {
      _residuosPendientes = List.from(_residuos)..shuffle();
      _ronda++;
    });
  }

  void _terminarJuego(bool gano) {
    _timerActivo = false;
    setState(() {
      _juegoTerminado = true;
      _juegoGanado = gano;
      if (gano) {
        _mensaje = '¡Felicidades! 🏆';
        if (!_monedasOtorgadas) {
          _otorgarMonedas();
        }
      } else {
        _mensaje = '¡Se acabó el tiempo! ⏰';
      }
    });
  }

  Future<void> _otorgarMonedas() async {
    _monedasOtorgadas = true;
    final monedasService = MonedasService();
    await monedasService.init();
    await monedasService.agregarMonedas(15);
    await SoundService.instance.monedasGanadas();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Ganaste 15 monedas! 🪙'),
          backgroundColor: AppTheme.verde,
        ),
      );
    }
  }

  void _verificarRespuesta(
      Map<String, dynamic> residuo, bool contenedorComposta) {
    if (_juegoTerminado) return;

    if (residuo['correcto'] == contenedorComposta) {
      setState(() {
        _aciertos++;
        if (_aciertos >= 3) {
          LogrosService().desbloquearInsignia('clasificador');
        }
        _mensaje =
            '✅ ¡Correcto! ${residuo['emoji']} va ${contenedorComposta ? "en la composta" : "en la basura"}';
        _residuosPendientes.remove(residuo);
      });

      SoundService.instance.retoCompletado();

      // ✅ Verificar si llegó a la meta
      if (_aciertos >= _metaAciertos) {
        _terminarJuego(true);
        return;
      }
    } else {
      setState(() {
        _errores++;
        _mensaje =
            '❌ ¡Ups! ${residuo['emoji']} NO va ${contenedorComposta ? "en la composta" : "en la basura"}';
      });
    }

    if (_residuosPendientes.isEmpty && !_juegoTerminado) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_juegoTerminado) _iniciarRonda();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58CC71),
      appBar: AppBar(
        title: const Text('♻️ Clasifica residuos'),
        backgroundColor: AppTheme.verde,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⭐ $_aciertos/$_metaAciertos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      // ✅ FONDO EN EL BODY
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
          child: _juegoTerminado
              ? _buildPantallaFinal()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
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
                      children: [
                        // ✅ Barra de tiempo y progreso
                        Row(
                          children: [
                            // Tiempo
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _segundosRestantes <= 10
                                    ? Colors.red.withValues(alpha: 0.15)
                                    : AppTheme.verde.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: _segundosRestantes <= 10
                                        ? Colors.red
                                        : AppTheme.verde,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_segundosRestantes s',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _segundosRestantes <= 10
                                          ? Colors.red
                                          : AppTheme.verde,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Progreso
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Meta: $_metaAciertos aciertos',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.cafe,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  LinearProgressIndicator(
                                    value: _aciertos / _metaAciertos,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation<
                                        Color>(AppTheme.verde),
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Mensaje
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.verde.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _mensaje,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Fredoka',
                              color: AppTheme.cafe,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ✅ Contenedores
                        Row(
                          children: [
                            Expanded(
                              child: _buildContenedor(
                                  '🪱 Composta', AppTheme.verde, true),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildContenedor(
                                  '🗑️ Basura', Colors.red, false),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ✅ Residuos para arrastrar
                        if (_residuosPendientes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('¡Cargando nuevos residuos! 🎉',
                                style: TextStyle(fontSize: 16)),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _residuosPendientes.map((residuo) {
                              return _buildResiduo(residuo);
                            }).toList(),
                          ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContenedor(String label, Color color, bool esComposta) {
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (detalles) {
        _verificarRespuesta(detalles.data, esComposta);
      },
      builder: (context, candidatos, rechazados) {
        final tieneCandidatos = candidatos.isNotEmpty;
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: tieneCandidatos
                ? color.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tieneCandidatos ? color : color.withValues(alpha: 0.5),
              width: tieneCandidatos ? 3 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label.split(' ')[0], style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Fredoka',
                ),
              ),
              if (tieneCandidatos)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('¡Suelta aquí!',
                      style: TextStyle(fontSize: 11, color: AppTheme.cafe)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResiduo(Map<String, dynamic> residuo) {
    return Draggable<Map<String, dynamic>>(
      data: residuo,
      feedback: _tarjetaResiduo(residuo, true),
      childWhenDragging:
          Opacity(opacity: 0.3, child: _tarjetaResiduo(residuo, false)),
      child: _tarjetaResiduo(residuo, false),
    );
  }

  Widget _tarjetaResiduo(Map<String, dynamic> residuo, bool esFeedback) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: esFeedback ? AppTheme.amarillo : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: esFeedback
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
              ],
        border: Border.all(color: AppTheme.cafe.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(residuo['emoji'], style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 2),
          Text(
            residuo['nombre'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppTheme.cafe),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPantallaFinal() {
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
              Text(_juegoGanado ? '🏆' : '⏰',
                  style: const TextStyle(fontSize: 70)),
              const SizedBox(height: 16),
              Text(
                _mensaje,
                style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    color: AppTheme.verde),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildEstadistica('✅ Aciertos', _aciertos, AppTheme.verd  e),
              _buildEstadistica('❌ Errores', _errores, Colors.red),
              _buildEstadistica(
                  '⏱️ Tiempo', _tiempoLimite - _segundosRestantes, Colors.blue),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _iniciarJuego,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  '🔄 Jugar de nuevo',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadistica(String label, int valor, Color color) {
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
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$valor',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}