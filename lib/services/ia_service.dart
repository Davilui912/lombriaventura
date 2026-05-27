import 'package:google_generative_ai/google_generative_ai.dart';

class IAService {
  // ⚠️ PEGA AQUÍ TU NUEVA API KEY
  static const String _apiKey = 'AIzaSyBib7qzmsaB-SfTTOS6H-yKer4HHwnZNtI';

  // Historial de conversación
  final List<Map<String, dynamic>> _historial = [];
  int _contadorPreguntas = 0;
  String _fechaHoy = '';

  // Prompt de sistema con la personalidad de Lola
  static const String _instruccionesLola = '''
Eres Lola, una lombriz de composta muy alegre, divertida y amigable 🪱.
Tu misión es enseñar a niños y niñas de 9 a 12 años sobre ecología, reciclaje y cómo hacer composta.

REGLAS OBLIGATORIAS:
1. Responde SIEMPRE en español.
2. Usa un tono cariñoso, palabras sencillas y explicaciones cortas (máximo 4 oraciones).
3. Usa emojis de naturaleza: 🪱🌱🍎♻️🌍
4. Dirígete de forma inclusiva: "amiguito o amiguita", "peques".
5. Si la pregunta NO es sobre lombrices, compostaje, plantas, reciclaje o ecología, responde:
   "¡Uy! Eso no es de mi especialidad. Mejor pregúntame sobre lombrices, composta o cómo cuidar las plantitas. 🌱"
6. Si te preguntan algo inapropiado, responde:
   "Prefiero no hablar de eso. ¡Hablemos de la composta mejor! 🪱"
''';

  List<Map<String, dynamic>> obtenerHistorial() {
    return List.from(_historial);
  }

  int preguntasRestantes() {
    _verificarNuevoDia();
    const limite = 15;
    return (limite - _contadorPreguntas).clamp(0, limite);
  }

  void _verificarNuevoDia() {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    if (_fechaHoy != hoy) {
      _fechaHoy = hoy;
      _contadorPreguntas = 0;
    }
  }

  Future<String> preguntar(String textoDelNino) async {
    _verificarNuevoDia();

    // Verificar límite diario
    if (_contadorPreguntas >= 15) {
      return '¡Guau! Ya hiciste muchas preguntas hoy. ¡Qué curioso eres! Regresa mañana y seguimos aprendiendo juntos. 🌟';
    }

    try {
      // 1. Crear el modelo con instrucciones de sistema
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_instruccionesLola),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 150,
          topP: 0.8,
        ),
      );

      // 2. Construir historial para el chat
      final List<Content> chatHistory = [];
      
      // Solo incluir últimos 5 intercambios para contexto
      final historialRelevante = _historial.take(10).toList();
      for (var mensaje in historialRelevante.reversed) {
        chatHistory.add(Content.text(mensaje['pregunta']));
        if (mensaje['respuesta'] != null && mensaje['respuesta'].toString().isNotEmpty) {
          chatHistory.add(Content.model([TextPart(mensaje['respuesta'])]));
        }
      }

      // 3. Iniciar chat con historial
      final chat = model.startChat(history: chatHistory);

      // 4. Enviar pregunta
      final response = await chat.sendMessage(Content.text(textoDelNino));
      final String respuestaLola = response.text ?? '¡Uy! Me quedé sin palabras, peque. 🪱';

      // 5. Incrementar contador
      _contadorPreguntas++;

      // 6. Guardar en historial
      _historial.insert(0, {
        'pregunta': textoDelNino,
        'respuesta': respuestaLola,
        'fecha': DateTime.now().toIso8601String(),
      });

      // Mantener solo últimos 30 mensajes
      if (_historial.length > 30) {
        _historial.removeLast();
      }

      print('✅ Lola respondió: $respuestaLola');
      return respuestaLola;

    } catch (e) {
      print('❌ ERROR GEMINI: $e');
      
      // Si falla la API, usar respuesta de respaldo
      return _obtenerRespuestaRespaldo(textoDelNino);
    }
  }

  // Respuestas de respaldo por si falla la API
  String _obtenerRespuestaRespaldo(String pregunta) {
    final preguntaLower = pregunta.toLowerCase();
    
    if (preguntaLower.contains('comen') || preguntaLower.contains('comida')) {
      return '¡Nos encantan las cáscaras de frutas y verduras! 🍎🥕 También el café molido y cáscaras de huevo. ¡Pero nada de carne ni lácteos! 🪱';
    } else if (preguntaLower.contains('composta') || preguntaLower.contains('hacer')) {
      return '¡Es muy fácil! Necesitas un contenedor, lombrices, tierra y restos de comida. ¡Nosotras hacemos el trabajo! 🌱';
    } else if (preguntaLower.contains('humedad') || preguntaLower.contains('agua')) {
      return 'La composta debe estar húmeda como una esponja exprimida. Si está seca, rocía un poco de agua. 💧';
    } else if (preguntaLower.contains('hola')) {
      return '¡Hola, peque! 🪱 Soy Lola, tu amiga lombriz. ¿Quieres aprender sobre compostaje hoy?';
    } else {
      return '¡Qué buena pregunta! 🪱 Aunque mi lombri-cerebro está un poco lento ahora. ¿Me preguntas de nuevo? 🌱';
    }
  }
}