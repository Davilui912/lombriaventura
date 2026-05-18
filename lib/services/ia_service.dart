import 'dart:math';

class IAService {
  // MODO SIMULACIÓN: Cambia a false cuando tengas una API real
  static const bool _modoSimulacion = true;

  final List<Map<String, dynamic>> _historial = [];

  // Base de conocimientos de Lola
  static final Map<String, List<String>> _respuestasPredefinidas = {
    'lombrices': [
      '¡Las lombrices somos increíbles! 🪱 Vivimos en la tierra, comemos restos de comida y hacemos el mejor fertilizante del mundo: ¡el humus!',
      'Somos pequeñas pero poderosas. Ayudamos a que las plantas crezcan fuertes y sanas. ¡Somos las mejores amigas de tu jardín! 🌱',
      '¿Sabías que respiramos por la piel? Por eso necesitamos vivir en lugares húmedos. ¡El agua es nuestra aliada! 💧',
    ],
    'comen': [
      '¡Nos encantan las cáscaras de frutas y verduras! 🍎🥕 También el café molido, cáscaras de huevo trituradas y hojas secas. ¡Pero nada de carne ni lácteos!',
      'Somos vegetarianas. Comemos restos de cocina como cáscaras, pero no nos des cítricos en exceso ni cebolla. ¡Ayudamos a reciclar! ♻️',
    ],
    'composta': [
      'La lombricomposta es como una granja de lombrices donde convertimos tus residuos en tierra mágica para las plantas. 🌱✨',
      '¡Es súper fácil! Necesitas un contenedor, lombrices, tierra y restos de comida. Nosotras hacemos el trabajo pesado. 🪱',
      'Hacer composta ayuda al planeta. Reduces basura y obtienes el mejor abono natural. ¡Tus plantas te lo agradecerán! 🌍',
    ],
    'residuos': [
      'Puedes usar: cáscaras de frutas 🍌, verduras 🥕, café ☕, hojas secas 🍂, y cáscaras de huevo trituradas 🥚. ¡Nada de plástico o metal!',
      'Los residuos orgánicos son nuestro buffet favorito. Recuerda cortarlos en trocitos pequeños para que podamos comerlos más fácil. ✂️',
    ],
    'reciclar': [
      'Reciclar es darle una segunda vida a las cosas. ¡Con la lombricomposta reciclas tus residuos de cocina y ayudas al planeta! 🌍♻️',
      'Cuando reciclas con nosotras, conviertes basura en tesoro. ¡El humus que producimos es oro negro para las plantas! 🌱✨',
    ],
    'plantas': [
      'Las plantas aman nuestro humus. Crece más rápido, más fuerte y más sano. ¡Es como un súper alimento para ellas! 🌻',
      'Con lombricomposta, tus plantas tendrán flores más bonitas y frutos más sabrosos. ¡La naturaleza es sabia! 🌸',
    ],
    'humus': [
      'El humus es el tesoro que producimos las lombrices. Es un abono natural que huele a tierra fresca y hace felices a las plantas. 🪱✨',
      'Cosechar humus es muy gratificante. Después de 2-3 meses, tendrás el mejor fertilizante del mundo. ¡Gratis y ecológico! 🌱',
    ],
  };

  // Respuestas para cuando no encuentra tema
  static final List<String> _respuestasFueraTema = [
    '¡Uy! Eso no es de mi especialidad. Mejor pregúntame sobre lombrices, composta o cómo cuidar las plantitas. 🌱',
    '¡Vaya! De eso no sé mucho. Pero si quieres saber de compostaje, ¡soy una experta! 🪱',
    'Hmm, déjame pensar... ¡Mejor hablemos de cómo hacer composta juntos! ¿Te parece? ♻️',
  ];

  // Saludos
  static final Map<String, String> _saludos = {
    'hola': '¡Hola, peque! 🪱 Soy Lola, tu amiga lombriz. ¿Quieres aprender sobre compostaje hoy?',
    'buenos días': '¡Buenos días, amiguito o amiguita! ☀️ ¿Listo para cuidar el planeta conmigo?',
    'buenas tardes': '¡Buenas tardes! 🌤️ ¿Vamos a aprender algo divertido sobre lombrices?',
    'gracias': '¡De nada, peque! Me encanta enseñarte. ¿Alguna otra pregunta? 🌟',
    'adiós': '¡Hasta luego, Eco Héroe! Vuelve pronto a cuidar el planeta conmigo. 🪱💚',
  };

  List<Map<String, dynamic>> obtenerHistorial() {
    return List.from(_historial);
  }

  int preguntasRestantes() {
    if (_modoSimulacion) return 999; // Ilimitado en modo simulación
    const limite = 15;
    return (limite - _historial.length).clamp(0, limite);
  }

  String _buscarRespuestaLocal(String pregunta) {
    final preguntaLower = pregunta.toLowerCase().trim();

    // 1. Verificar saludos
    for (var entrada in _saludos.entries) {
      if (preguntaLower.contains(entrada.key)) {
        return entrada.value;
      }
    }

    // 2. Buscar en la base de conocimientos
    for (var tema in _respuestasPredefinidas.entries) {
      if (preguntaLower.contains(tema.key)) {
        final respuestas = tema.value;
        return respuestas[Random().nextInt(respuestas.length)];
      }
    }

    // 3. Si la pregunta es muy corta (probablemente sin sentido)
    if (preguntaLower.length < 3) {
      return 'No entendí muy bien, peque. ¿Puedes hacer una pregunta más larga? 🪱';
    }

    // 4. Respuesta fuera de tema
    return _respuestasFueraTema[Random().nextInt(_respuestasFueraTema.length)];
  }

  Future<String> preguntar(String textoDelNino) async {
    if (_modoSimulacion) {
      // Simular un pequeño delay para que parezca real
      await Future.delayed(const Duration(milliseconds: 800));
      
      final respuesta = _buscarRespuestaLocal(textoDelNino);
      
      _historial.insert(0, {
        'pregunta': textoDelNino,
        'respuesta': respuesta,
        'fecha': DateTime.now().toIso8601String(),
      });

      if (_historial.length > 30) _historial.removeLast();

      return respuesta;
    }

    // Aquí iría la conexión a API real cuando la tengas
    return 'Modo API no configurado. Activa el modo simulación.';
  }

  /// Método para recargar conocimiento (útil en futuro)
  void agregarConocimiento(String tema, List<String> respuestas) {
    _respuestasPredefinidas[tema] = respuestas;
  }
}