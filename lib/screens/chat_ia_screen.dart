import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../config/theme.dart';
import '../services/groq_service.dart';
import '../services/conversacion_service.dart';
import '../models/conversacion.dart';
import 'historial_chat_screen.dart'; // Lo crearemos después
import 'dart:math';

class ChatIAScreen extends StatefulWidget {
  final String? conversacionId; // Para cargar conversación existente
  const ChatIAScreen({super.key, this.conversacionId});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroqService _iaService = GroqService();
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  final ConversacionService _convService = ConversacionService();
  
  List<Map<String, String>> _mensajes = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _vozAutomatica = true;
  
  String? _conversacionActualId;
  String _conversacionTitulo = '';
  
  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSpeech();
    _cargarConversacion();
  }
  
  // ========== CARGAR CONVERSACIÓN ==========

  Future<void> _cargarConversacion() async {
    if (widget.conversacionId != null) {
      final conversacion = await _convService.obtenerPorId(widget.conversacionId!);
      if (conversacion != null) {
        setState(() {
          _mensajes = List.from(conversacion.mensajes);
          _conversacionActualId = conversacion.id;
          _conversacionTitulo = conversacion.titulo;
        });
        _scrollToBottom();
        return;
      }
    }
    _agregarMensajeBienvenida();
  }
  
  void _agregarMensajeBienvenida() {
    _mensajes = [{
      'role': 'lola',
      'content': '¡Hola, Eco Héroe! 🪱 Soy Lola, tu lombriz experta.\n\nPregúntame sobre lombrices, composta y cómo cuidar el planeta. ¡Estoy aquí para ayudarte! 🌱✨\n\n🔊 Puedes activar o desactivar mi voz con el botón de la esquina.',
    }];
    _conversacionActualId = null;
    _conversacionTitulo = '';
  }
  
  // ✅ Guardar conversación automáticamente
  Future<void> _guardarConversacion() async {
    if (_mensajes.isEmpty) return;
    
    // Solo guardar si hay más de 1 mensaje (bienvenida + alguna pregunta)
    if (_mensajes.length <= 1) return;
    
    final id = _conversacionActualId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final titulo = _conversacionTitulo.isEmpty && _mensajes.length > 1
        ? _convService.generarTitulo(_mensajes[1]['content'] ?? 'Nueva conversación')
        : _conversacionTitulo;
    
    final conversacion = Conversacion(
      id: id,
      titulo: titulo,
      fecha: DateTime.now(),
      mensajes: List.from(_mensajes),
    );
    
    await _convService.guardarConversacion(conversacion);
    if (_conversacionActualId == null) {
      _conversacionActualId = id;
    }
    if (_conversacionTitulo.isEmpty && _mensajes.length > 1) {
      _conversacionTitulo = titulo;
    }
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
    
    // Agregar mensaje del usuario
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
      
      // ✅ Guardar conversación después de cada interacción
      await _guardarConversacion();
      
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
      await _guardarConversacion();
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
  
  // ✅ Nueva conversación
  void _nuevaConversacion() {
    setState(() {
      _mensajes = [];
      _conversacionActualId = null;
      _conversacionTitulo = '';
      _agregarMensajeBienvenida();
    });
  }
  
  // ✅ Ir al historial
  void _verHistorial() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistorialChatScreen()),
    );
    if (result != null && result is String) {
      _cargarConversacionPorId(result);
    }
  }
  
  Future<void> _cargarConversacionPorId(String id) async {
    final conversacion = await _convService.obtenerPorId(id);  // ✅ Con await
    if (conversacion != null) {
      setState(() {
        _mensajes = List.from(conversacion.mensajes);
        _conversacionActualId = conversacion.id;
        _conversacionTitulo = conversacion.titulo;
      });
      _scrollToBottom();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final preguntasRestantes = _iaService.preguntasRestantesHoy;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lola'),
        backgroundColor: AppTheme.verde,
        actions: [
          // ✅ Botón nueva conversación
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: _nuevaConversacion,
            tooltip: 'Nueva conversación',
          ),
          // ✅ Botón historial
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _verHistorial,
            tooltip: 'Historial',
          ),
          // Botón de voz
          IconButton(
            icon: Icon(
              _vozAutomatica ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _vozAutomatica = !_vozAutomatica);
              if (!_vozAutomatica && _isSpeaking) _detenerLectura();
            },
          ),
          // Contador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$preguntasRestantes/30',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_vozAutomatica)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.grey.shade200,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_off, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Voz desactivada', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
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
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.verde),
            onPressed: () => _enviarMensaje(),
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