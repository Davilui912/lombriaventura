import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config.dart';

class GroqService {
  static const String _apiKey = AppConfig.groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  String _manualCompleto = '';
  static int _preguntasHoy = 0;
  static String _ultimaFecha = '';
  
  GroqService() {
    _cargarManual();
  }
  
  Future<void> _cargarManual() async {
    try {
      _manualCompleto = await rootBundle.loadString('assets/data/manual_lombrices.txt');
    } catch (e) {
      _manualCompleto = '';
    }
  }
  
  bool _puedePreguntarHoy() {
    final hoy = DateTime.now().toString().substring(0, 10);
    if (_ultimaFecha != hoy) {
      _preguntasHoy = 0;
      _ultimaFecha = hoy;
    }
    return _preguntasHoy < 30;
  }
  
  void _registrarPregunta() {
    _preguntasHoy++;
  }
  
  int get preguntasRestantesHoy => 30 - _preguntasHoy;
  
  Future<bool> _tieneInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  Future<String> preguntarALola(String pregunta) async {
    if (pregunta.trim().isEmpty) {
      return '¿Hola! Dime tu pregunta y te ayudaré.';
    }
    
    if (!_puedePreguntarHoy()) {
      return '🌟¡Guau! Ya hiciste 30 preguntas hoy. ¡Qué curioso eres! Regresa mañana.';
    }
    
    if (!await _tieneInternet()) {
      return _respuestaOffline(pregunta);
    }
    
    _registrarPregunta();
    
    try {
      final respuesta = await _preguntarGroq(pregunta);
      if (respuesta.isNotEmpty) {
        return respuesta;
      }
      return _respuestaOffline(pregunta);
    } catch (e) {
      print('Error en Groq: $e');
      return _respuestaOffline(pregunta);
    }
  }
  
  Future<String> _preguntarGroq(String pregunta) async {
    final promptSistema = '''
# ROL Y PERSONALIDAD
Actúa como una lombriz roja californiana simpática, sabia y entusiasta. Tu misión es ser la guía e instructora de niños de 6 a 12 años dentro de la aplicación educativa "Lombriaventura".

# OBJETIVO Y CONTEXTO
Tu propósito es educar y motivar a los niños a cuidar el planeta mediante el uso de lombrices. Debes responder dudas sobre:
- Biología y cuidados de las lombrices.
- Creación y mantenimiento de lombricomposta y composta casera.
- Reciclaje de residuos orgánicos y cuidado del medio ambiente y las plantas.
- Emprendimiento básico infantil: cómo iniciar un pequeño negocio de venta de lombrices o humus (abono), ideas de autoayuda y consejos sencillos para administrar su proyecto de lombrices.

# REGLAS ESTRICTAS DE FILTRADO (SAFETY GUARDRAILS)
1. Si el usuario te pregunta sobre CUALQUIER tema que NO esté relacionado con lombrices, medio ambiente, composta o el negocio de las lombrices, debes activar tu respuesta de rechazo.
2. Tu respuesta de rechazo debe ser EXACTAMENTE la siguiente frase, sin añadir nada más: 
"¡Uy! Esa pregunta no es de mi especialidad. Mejor pregúntame sobre lombrices."

# ESTILO Y FORMATO DE RESPUESTA
- Tono: Extremadamente alegre, animado, empático y adaptado para niños pequeños (usa analogías simples y metáforas divertidas).
- Brevedad: Mantén las respuestas muy cortas, concisas y resumidas. Evita textos largos o bloques densos para que los niños no se aburran al leer.Cada vez que quieras decirle amigo o lo que sea mejor dile lombrikid. Puedes usar viñetas (bullets) si es necesario.
- Perspectiva: Habla siempre en PRIMERA PERSONA (como si tú fueras la lombriz).
- Introducción Única: Preséntate diciendo "Soy la lombriz sabia..." ÚNICAMENTE en la primera interacción o pregunta del usuario. En las respuestas siguientes, ve directo al grano de forma amigable sin volver a presentarte.

MANUAL OFICIAL:
$_manualCompleto

PREGUNTA: $pregunta
RESPUESTA DE La lombriz sabia:
''';
    
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'system', 'content': 'Eres Lola la lombriz, experta en compostaje para niños.'},
          {'role': 'user', 'content': promptSistema},
        ],
        'temperature': 0.7,
        'max_tokens': 800,
        'top_p': 0.95,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final respuesta = data['choices'][0]['message']['content'].trim();
      return respuesta.isNotEmpty ? respuesta : _respuestaOffline(pregunta);
    } else {
      print('Error Groq: ${response.statusCode}');
      return _respuestaOffline(pregunta);
    }
  }
  
  String _respuestaOffline(String pregunta) {
    final preguntaLower = pregunta.toLowerCase();
    
    if (preguntaLower.contains('comen') || preguntaLower.contains('aliment')) {
      return '🍎 ¡Nos encantan las cáscaras de frutas y verduras! Hay que cortarlas en trozos pequeños y esperar días a que se fermenten. 🪱';
    }
    
    if (preguntaLower.contains('temperatura')) {
      return '🌡️ Estamos felices entre 15°C y 25°C. Si hace mucho frío o calor, podemos enfermarnos. ❄️🔥';
    }
    
    if (preguntaLower.contains('humedad')) {
      return '💧 La humedad ideal es como una esponja escurrida. Prueba del puño: aprieta y debe quedar como plastilina. 🖐️';
    }
    
    if (preguntaLower.contains('lixiviado')) {
      return '💧 El lixiviado es el líquido de la composta. ¡Es súper nutritivo! Se mezcla con 10 partes de agua. 🌱';
    }
    
    return '📚 ¡Buena pregunta, Lombrikid! Revisa los módulos educativos de Lombriaventura. 🌱✨';
  }
}