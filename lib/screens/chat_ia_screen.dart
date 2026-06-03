import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../config/theme.dart';
//import '../services/ia_service.dart';
import '../services/groq_service.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  //final IaService _iaService = IaService();
  final GroqService _iaService = GroqService();
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  
  List<Map<String, String>> _mensajes = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _vozAutomatica = false;  // ✅ Control de voz automática
  
  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSpeech();
    _agregarMensajeBienvenida();
  }
  
  Future<void> _initTTS() async {
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setPitch(1.2);
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }
  
  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }
  
  void _agregarMensajeBienvenida() {
    _mensajes.add({
      'role': 'lola',
      'content': '¡Hola, Eco Héroe! 🪱 Soy Lola, tu lombriz experta.\n\nPregúntame sobre lombrices, composta y cómo cuidar el planeta. ¡Estoy aquí para ayudarte! 🌱✨\n\n🔊 Puedes activar o desactivar mi voz con el botón de la esquina.',
    });
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _enviarMensaje({String? preguntaTexto}) async {
    final pregunta = preguntaTexto ?? _controller.text.trim();
    if (pregunta.isEmpty) return;
    
    setState(() {
      _mensajes.add({'role': 'user', 'content': pregunta});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();
    
    try {
      final respuesta = await _iaService.preguntarALola(pregunta);
      
      setState(() {
        _mensajes.add({'role': 'lola', 'content': respuesta});
        _isLoading = false;
      });
      _scrollToBottom();
      
      // ✅ Solo leer automáticamente si la voz está activada
      if (_vozAutomatica) {
        await _leerRespuesta(respuesta);
      }
    } catch (e) {
      setState(() {
        _mensajes.add({
          'role': 'lola',
          'content': '¡Uy! Tuve un problema. ¿Puedes intentar de nuevo? 🪱'
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }
  
  Future<void> _leerRespuesta(String texto) async {
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(texto);
  }
  
  Future<void> _detenerLectura() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }
  
  Future<void> _escucharPregunta() async {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }
    
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _isListening = false;
              _controller.text = result.recognizedWords;
            });
            _enviarMensaje(preguntaTexto: result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        localeId: 'es-MX',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final preguntasRestantes = _iaService.preguntasRestantesHoy;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.chat, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Pregúntale a Lola'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$preguntasRestantes/15',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            // ✅ Botón para activar/desactivar voz automática
            IconButton(
              icon: Icon(
                _vozAutomatica ? Icons.volume_up : Icons.volume_off,
                color: _vozAutomatica ? Colors.white : Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _vozAutomatica = !_vozAutomatica;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _vozAutomatica 
                        ? '🔊 Voz de Lola ACTIVADA' 
                        : '🔇 Voz de Lola DESACTIVADA',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
                if (!_vozAutomatica && _isSpeaking) {
                  _detenerLectura();
                }
              },
              tooltip: _vozAutomatica ? 'Desactivar voz' : 'Activar voz',
            ),
          ],
        ),
        backgroundColor: AppTheme.verde,
      ),
      body: Column(
        children: [
          // ✅ Indicador cuando la voz está desactivada
          if (!_vozAutomatica)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_off, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    'Voz desactivada - Lola no leerá las respuestas',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mensajes.length && _isLoading) {
                  return _buildLoadingIndicator();
                }
                final mensaje = _mensajes[index];
                return _buildMensaje(
                  mensaje['content']!,
                  esUsuario: mensaje['role'] == 'user',
                );
              },
            ),
          ),
          
          // Área de entrada
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildMensaje(String texto, {required bool esUsuario}) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: esUsuario ? AppTheme.verde : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: esUsuario ? const Radius.circular(20) : Radius.zero,
            bottomRight: esUsuario ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texto,
                style: TextStyle(
                  color: esUsuario ? Colors.white : AppTheme.cafe,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              // ✅ Botón manual "Escuchar" (siempre visible para mensajes de Lola)
              if (!esUsuario)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSpeaking ? Icons.stop : Icons.volume_up,
                          size: 18,
                        ),
                        color: AppTheme.verde,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: _isSpeaking ? _detenerLectura : () => _leerRespuesta(texto),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSpeaking ? '🔴 Leyendo...' : '🔊 Escuchar',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
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
  
  Widget _buildLoadingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.verde),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : AppTheme.cafe,
            ),
            onPressed: _escucharPregunta,
            iconSize: 30,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.verde),
            onPressed: () => _enviarMensaje(),
            iconSize: 30,
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }
}