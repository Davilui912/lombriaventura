import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/ia_service.dart';
import '../config/theme.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final IAService _iaService = IAService();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speechToText;

  List<Map<String, dynamic>> _mensajes = [];
  bool _cargando = false;
  bool _escuchando = false;
  int _preguntasRestantes = 15;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _cargarHistorial();
    _configurarTTS();
    _actualizarContador();
  }

  void _configurarTTS() {
    _flutterTts.setLanguage('es-MX');
    _flutterTts.setSpeechRate(0.5); // Velocidad para niños
    _flutterTts.setPitch(1.2); // Tono más agudo (voz infantil)
  }

  void _cargarHistorial() {
    setState(() {
      _mensajes = _iaService.obtenerHistorial();
    });
  }

  void _actualizarContador() {
    setState(() {
      _preguntasRestantes = _iaService.preguntasRestantes();
    });
  }

  Future<void> _enviarPregunta(String texto) async {
    if (texto.trim().isEmpty) return;

    setState(() => _cargando = true);
    _controller.clear();

    // Mostrar pregunta del niño inmediatamente
    setState(() {
      _mensajes.insert(0, {
        'pregunta': texto,
        'respuesta': '',
        'fecha': DateTime.now().toIso8601String(),
        'cargando': true,
      });
    });

    // Obtener respuesta de Lola
    final respuesta = await _iaService.preguntar(texto);

    // Actualizar mensaje con la respuesta
    setState(() {
      _mensajes[0]['respuesta'] = respuesta;
      _mensajes[0]['cargando'] = false;
      _cargando = false;
    });

    _actualizarContador();
    _scrollToBottom();
  }

  Future<void> _iniciarDictado() async {
    if (!_escuchando) {
      bool disponible = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _escuchando = false);
          }
        },
        onError: (error) {
          setState(() => _escuchando = false);
        },
      );

      if (disponible) {
        setState(() => _escuchando = true);
        _speechToText.listen(
          onResult: (result) {
            _controller.text = result.recognizedWords;
            if (result.finalResult) {
              setState(() => _escuchando = false);
              _enviarPregunta(result.recognizedWords);
            }
          },
          localeId: 'es_MX',
        );
      }
    } else {
      setState(() => _escuchando = false);
      _speechToText.stop();
    }
  }

  Future<void> _leerRespuesta(String texto) async {
    if (texto.isNotEmpty) {
      await _flutterTts.speak(texto);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖 Pregúntale a Lola'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '$_preguntasRestantes',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: _mensajes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      return _buildBurbujaMensaje(_mensajes[index]);
                    },
                  ),
          ),

          // Barra de escritura
          _buildInputBar(),
        ],
      ),
    );
  }

Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 80, color: AppTheme.verde),
            const SizedBox(height: 20),
            const Text(
              '¡Pregúntame lo que quieras!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                color: AppTheme.verde,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(   // ← AQUÍ VA child:
                children: [
                  _SugerenciaPregunta(
                    texto: '🪱 ¿Qué comen las lombrices?',
                    onTapSugerencia: (texto) => _enviarPregunta(texto),
                  ),
                  _SugerenciaPregunta(
                    texto: '🌱 ¿Cómo hago composta?',
                    onTapSugerencia: (texto) => _enviarPregunta(texto),
                  ),
                  _SugerenciaPregunta(
                    texto: '♻️ ¿Qué residuos puedo usar?',
                    onTapSugerencia: (texto) => _enviarPregunta(texto),
                  ),
                  _SugerenciaPregunta(
                    texto: '🌍 ¿Por qué es bueno reciclar?',
                    onTapSugerencia: (texto) => _enviarPregunta(texto),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBurbujaMensaje(Map<String, dynamic> mensaje) {
    final cargando = mensaje['cargando'] == true;
    final tieneRespuesta = mensaje['respuesta'] != null && 
                           mensaje['respuesta'].toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta del niño (alineada a la derecha)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.azulCielo,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mensaje['pregunta'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatearHora(mensaje['fecha']),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Respuesta de Lola (alineada a la izquierda)
          if (tieneRespuesta || cargando)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar de Lola
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppTheme.verde,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🪱', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  // Burbuja de respuesta
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: cargando
                        ? const _BurbujaCargando()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mensaje['respuesta'],
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _leerRespuesta(
                                    mensaje['respuesta']),
                                child: const Icon(
                                  Icons.volume_up,
                                  size: 22,
                                  color: AppTheme.verde,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de micrófono
          GestureDetector(
            onTap: _iniciarDictado,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _escuchando ? Colors.red : AppTheme.verde,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _escuchando ? Icons.mic : Icons.mic_none,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Campo de texto
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (texto) => _enviarPregunta(texto),
            ),
          ),
          const SizedBox(width: 10),
          // Botón de enviar
          GestureDetector(
            onTap: () => _enviarPregunta(_controller.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppTheme.verde,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearHora(String? fechaIso) {
    if (fechaIso == null) return '';
    try {
      final fecha = DateTime.parse(fechaIso);
      final hora = '${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
      return hora;
    } catch (e) {
      return '';
    }
  }
}

// Widget de sugerencias de preguntas
class _SugerenciaPregunta extends StatelessWidget {
  final String texto;
  final Function(String) onTapSugerencia;
  
  const _SugerenciaPregunta({
    required this.texto,
    required this.onTapSugerencia,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () => onTapSugerencia(texto),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9EE),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.verde.withValues(alpha: 0.3)),
          ),
          child: Text(
            texto,
            style: const TextStyle(fontSize: 15, color: AppTheme.cafe),
          ),
        ),
      ),
    );
  }
}

// Indicador de "Lola está escribiendo..."
class _BurbujaCargando extends StatefulWidget {
  const _BurbujaCargando();

  @override
  State<_BurbujaCargando> createState() => _BurbujaCargandoState();
}

class _BurbujaCargandoState extends State<_BurbujaCargando>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _puntoAnimado(0),
        const SizedBox(width: 4),
        _puntoAnimado(1),
        const SizedBox(width: 4),
        _puntoAnimado(2),
      ],
    );
  }

 Widget _puntoAnimado(int index) {
    final delay = index * 0.2;
    final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
    final opacity = 0.3 + (value * 0.7);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppTheme.verde,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}