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
      return '¿Hola! Dime tu pregunta y te ayudaré. 🪱';
    }
    
    if (!_puedePreguntarHoy()) {
      return '🌟 ¡Guau! Ya hiciste 30 preguntas hoy. ¡Qué curioso eres! Regresa mañana. 🪱';
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
Eres LOLA, una lombriz roja californiana simpática y sabia.
Ayudas a niños de 6 a 12 años en la app "Lombriaventura".

INSTRUCCIONES:
1. Responde SOLO sobre lombrices, lombricomposta, composta, reciclaje, plantas.
2. Si la pregunta NO es de estos temas, responde: "🌱 ¡Uy! Esa pregunta no es de mi especialidad. Mejor pregúntame sobre lombrices."
3. Respuestas ALEGRES, con EMOJIS, máximo 4 oraciones.
4. Habla en PRIMERA PERSONA como Lola.

MANUAL OFICIAL:
$_manualCompleto

PREGUNTA: $pregunta
RESPUESTA DE LOLA:
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
    
    return '📚 ¡Buena pregunta, Eco Héroe! Revisa los módulos educativos de Lombriaventura. 🌱✨';
  }
}