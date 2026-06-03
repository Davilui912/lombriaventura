import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
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
    return _preguntasHoy < 30; // 30 preguntas gratis por día
  }
  
  void _registrarPregunta() {
    _preguntasHoy++;
  }
  
  int get preguntasRestantesHoy => 30 - _preguntasHoy;
  
  Future<String> preguntarALola(String pregunta) async {
    if (pregunta.trim().isEmpty) {
      return '¿Hola! Dime tu pregunta y te ayudaré. 🪱';
    }
    
    if (!_puedePreguntarHoy()) {
      return '🌟 ¡Guau! Ya hiciste 30 preguntas hoy. ¡Qué curioso eres! Regresa mañana. 🪱';
    }
    
    _registrarPregunta();
    
    final prompt = '''
Eres LOLA, una lombriz roja californiana simpática y sabia.
Ayudas a niños de 6 a 12 años.

REGLAS:
1. Responde SOLO sobre lombrices, lombricomposta, composta, residuos orgánicos, reciclaje, plantas.
2. Si la pregunta NO es de estos temas, responde: "🌱 ¡Uy! Esa pregunta no es de mi especialidad. Mejor pregúntame sobre lombrices."
3. Respuestas ALEGRES, con EMOJIS, máximo 3-4 oraciones.
4. Habla en PRIMERA PERSONA como Lola.

MANUAL OFICIAL (USA SOLO ESTO):
$_manualCompleto

PREGUNTA DEL NIÑO: $pregunta

RESPUESTA DE LOLA:
''';
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant', // Modelo gratuito y rápido
          'messages': [
            {'role': 'system', 'content': 'Eres Lola la lombriz, experta en compostaje.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 900,
          'top_p': 0.95,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final respuesta = data['choices'][0]['message']['content'];
        return respuesta.trim();
      } else {
        return _respuestaOffline(pregunta);
      }
    } catch (e) {
      return _respuestaOffline(pregunta);
    }
  }
  
  String _respuestaOffline(String pregunta) {
    final preguntaLower = pregunta.toLowerCase();
    
    if (preguntaLower.contains('comen')) {
      return '🍎 ¡Nos encantan las cáscaras de frutas y verduras en trozos pequeños! No comemos nada fresquito, hay que esperar días a que fermente. 🪱';
    }
    if (preguntaLower.contains('nacen')) {
      return '🥚 Ponemos huevitos en capullos cada 10 días. Nacen 2-5 bebés que tardan 2-3 meses en ser adultas. 🪱✨';
    }
    if (preguntaLower.contains('temperatura')) {
      return '🌡️ Estamos felices entre 15°C y 25°C. Ni mucho frío ni mucho calor. ❄️🔥';
    }
    if (preguntaLower.contains('humedad')) {
      return '💧 La humedad ideal es como una esponja escurrida. Prueba del puño: aprieta y debe quedar como plastilina. 🖐️';
    }
    
    return '📚 ¡Buena pregunta! Revisa los módulos educativos de Lombriaventura o pregúntame de nuevo. 🌱';
  }
}