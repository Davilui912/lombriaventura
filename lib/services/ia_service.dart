import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class IaService {
  String _manualCompleto = '';
  
  static int _preguntasHoy = 0;
  static String _ultimaFecha = '';
  
  IaService() {
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
    return _preguntasHoy < 15;
  }
  
  void _registrarPregunta() {
    _preguntasHoy++;
  }
  
  int get preguntasRestantesHoy => 15 - _preguntasHoy;
  
  // ✅ Ahora solo usa respuestas offline (sin API)
  Future<String> preguntarALola(String pregunta) async {
    if (pregunta.trim().isEmpty) {
      return '¿Hola! Dime tu pregunta y te ayudaré. 🪱';
    }
    
    if (!_puedePreguntarHoy()) {
      return '🌟 ¡Guau! Ya hiciste 15 preguntas hoy. ¡Qué curioso eres! Regresa mañana y seguimos aprendiendo juntos. 🪱';
    }
    
    _registrarPregunta();
    
    // ✅ Respuesta basada en el manual
    return _respuestaOffline(pregunta);
  }
  
  String _respuestaOffline(String pregunta) {
    final preguntaLower = pregunta.toLowerCase();
    
    // ========== RESPUESTAS BASADAS EN TU MANUAL ==========
    
    if (preguntaLower.contains('comen') || preguntaLower.contains('aliment')) {
      return '🍎 ¡Nos encantan las cáscaras de frutas y verduras! Pero OJO: hay que cortarlas en trozos pequeños y esperar unos días a que se fermenten. ¡No comemos nada fresquito! También nos gusta el café, hojas secas, cartón mojado y cáscara de huevo triturada. ¿Sabías que no tenemos dientes? 🪱';
    }
    
    if (preguntaLower.contains('nacen') || preguntaLower.contains('bebés') || preguntaLower.contains('crían') || preguntaLower.contains('reproduc')) {
      return '🥚 Nos juntamos en pareja y compartimos una parte de nuestro cuerpo. Ponemos huevitos dentro de capullos ¡Cada 10 días! De cada capullo pueden nacer entre 2 y 5 lombrices bebés. Las bebés tardan 2 o 3 meses en ser adultas (lo sabrás cuando veas un anillo en nuestro cuerpo). 🪱✨';
    }
    
    if (preguntaLower.contains('no pueden comer') || preguntaLower.contains('prohibido') || preguntaLower.contains('qué no')) {
      return '🚫 ¡NUNCA NOS DES! Carnes, huesos, lácteos, cítricos en exceso, sal, aceites, plásticos o químicos. Eso nos enferma o nos puede matar. Los cítricos dañan nuestra piel y la comida grasosa tapa el suelo. 🍋❌';
    }
    
    if (preguntaLower.contains('temperatura')) {
      return '🌡️ Estamos felices entre 15°C y 25°C. Si hace mucho frío (menos de 10°C) o mucho calor (más de 35°C), ¡podemos enfermarnos o morir! En invierno, méteme a la casa. En verano, a la sombra. ❄️🔥';
    }
    
    if (preguntaLower.contains('humedad') || preguntaLower.contains('agua') || preguntaLower.contains('prueba del puño')) {
      return '💧 La composta debe estar como una esponja escurrida. Haz la PRUEBA DEL PUÑO: toma un puñado de tierra, apriétalo suavemente. Si escurre agua → sobra. Si se desbarata como tierra seca → falta agua. Si queda como plastilina con la forma de tu puño → ¡perfecto! 🖐️';
    }
    
    if (preguntaLower.contains('lixiviado')) {
      return '💧 El lixiviado es el líquido que sale de la composta. ¡Es súper nutritivo! Se mezcla con 10 partes de agua y se echa a las plantas. ¡Les encanta! Pero ojo: el lixiviado de la basura común SÍ es tóxico, por eso separamos los residuos. 🌱';
    }
    
    if (preguntaLower.contains('hogar') || preguntaLower.contains('casa') || preguntaLower.contains('recipiente') || preguntaLower.contains('contenedor')) {
      return '🏠 Mi hogar perfecto necesita: 🌡️ temperatura 15-25°C, 💧 humedad como esponja, 🪱 una cama de hojas secas y cartón, 🍎 comida cada semana, y 🕳️ agujeros para que salga el lixiviado. ¡Y una malla para que no entren moscas! 🪰🚫';
    }
    
    if (preguntaLower.contains('que es la lombricomposta') || preguntaLower.contains('que es composta')) {
      return '♻️ La lombricomposta es un abono natural hecho por lombrices. Comen residuos orgánicos y los convierten en humus (tierra nutritiva) y lixiviado (líquido fertilizante). Ayuda a reducir la basura y hace felices a las plantas. 🌱';
    }
    
    if (preguntaLower.contains('como hacer') || preguntaLower.contains('hacer lombricomposta')) {
      return '🛠️ Para hacer lombricomposta: 1) Prepara un contenedor con agujeros, 2) Agrega cama de hojas secas y cartón, 3) Coloca las lombrices, 4) Añade residuos (80% carbono / 20% nitrógeno), 5) Mantén humedad y temperatura, 6) Espera 2-3 meses y cosecha el humus. ¡Es fácil! 🪱';
    }
    
    if (preguntaLower.contains('materiales')) {
      return '📦 Materiales: Contenedor con agujeros, lombrices californianas, fibra de coco o tierra, material seco (hojas, cartón), residuos orgánicos (cáscaras). ¡Con eso empiezas!';
    }
    
    if (preguntaLower.contains('balance') || preguntaLower.contains('80/20') || preguntaLower.contains('carbono') || preguntaLower.contains('nitrogeno')) {
      return '⚖️ Balance 80/20: 80% material SECO (carbono: hojas secas, cartón, papel) y 20% material VERDE (nitrógeno: cáscaras, restos de frutas/verduras, café). Demasiado verde = mal olor. Demasiado seco = proceso lento.';
    }
    
    if (preguntaLower.contains('cuidados')) {
      return '💚 Cuidados: 1) Humedad como esponja, 2) Temperatura 15-25°C, 3) Alimentación 1 vez por semana, 4) No dar alimentos prohibidos, 5) Proteger del sol y frío. ¡Así estamos felices!';
    }
    
    if (preguntaLower.contains('emprendimiento') || preguntaLower.contains('vender') || preguntaLower.contains('dinero')) {
  return '💰 ¡Sí! Puedes vender humus (composta) a \$50-100 MXN por kilo, lixiviado a \$30-50 MXN por litro, o vender lombrices a \$100-200 MXN por 100. ¡Ayudas al planeta y ganas dinero! 🪱✨';
    }
    if (preguntaLower.contains('problemas') || preguntaLower.contains('contaminacion') || preguntaLower.contains('basura')) {
      return '⚠️ La basura mezclada en vertederos produce LIXIVIADO TÓXICO que contamina el agua y el suelo. Por eso separamos los residuos orgánicos y hacemos composta. ¡Tú puedes ayudar! 🌍';
    }
    
    // Respuesta por defecto
    return '📚 ¡Buena pregunta, Lombikid! 🪱 Te recomiendo revisar los módulos educativos de Lombriaventura. Ahí encontrarás información sobre lombrices, composta y cómo cuidar el planeta. ¿Qué más te gustaría saber? 🌱✨';
  }
}