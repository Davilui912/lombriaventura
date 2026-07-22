import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../config/theme.dart';
import '../../services/actividad_service.dart';
import '../../services/monedas_service.dart';

class ProblemaMatematico {
  final String id;
  final String nivel;
  final String pregunta;
  final String respuestaCorrecta;
  final List<String> opciones;
  final int monedasGanadas;
  final String emoji;

  ProblemaMatematico({
    required this.id,
    required this.nivel,
    required this.pregunta,
    required this.respuestaCorrecta,
    required this.opciones,
    required this.monedasGanadas,
    required this.emoji,
  });
}

class ProblemasMatematicosScreen extends StatefulWidget {
  const ProblemasMatematicosScreen({super.key});

  @override
  State<ProblemasMatematicosScreen> createState() => _ProblemasMatematicosScreenState();
}

class _ProblemasMatematicosScreenState extends State<ProblemasMatematicosScreen> {
  final ActividadService _actividadService = ActividadService();
  String _nivelSeleccionado = 'base';
  int _problemaActualIndex = 0;
  int _puntaje = 0;
  int _monedasGanadas = 0;
  bool _mostrarResultado = false;
  bool _problemaRespondido = false;
  String _mensajeFeedback = '';
  Color _colorFeedback = AppTheme.verde;
  int _monedasActuales = 0;

  final List<ProblemaMatematico> _todosLosProblemas = [];

  List<ProblemaMatematico> get _problemasFiltrados {
    return _todosLosProblemas.where((p) => p.nivel == _nivelSeleccionado).toList();
  }

  @override
  void initState() {
    super.initState();
    _cargarProblemas();
    _inicializarMonedas(); // ✅ Inicializar MonedasService
    _cargarMonedasActuales();
    _verificarInstruccionesDelDia();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarMonedasActuales();
    });
  }

  // ✅ Nuevo método para inicializar MonedasService
  Future<void> _inicializarMonedas() async {
    try {
      await MonedasService().init();
      print('✅ MonedasService inicializado');
    } catch (e) {
      print('❌ Error inicializando MonedasService: $e');
    }
  }

  Future<void> _cargarMonedasActuales() async {
    try {
      // ✅ Usar el método obtenerMonedas del servicio
      final monedas = MonedasService().obtenerMonedas();
      setState(() {
        _monedasActuales = monedas;
      });
      print('🪙 Monedas cargadas: $_monedasActuales');
    } catch (e) {
      print('Error cargando monedas: $e');
    }
  }

  Future<int> _obtenerProblemasResueltosHoy() async {
    final box = await Hive.openBox('progreso_matematicas');
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    return box.get('problemas_resueltos_$hoy', defaultValue: 0);
  }

  Future<void> _guardarProblemaResueltoHoy() async {
    final box = await Hive.openBox('progreso_matematicas');
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    final actual = await _obtenerProblemasResueltosHoy();
    await box.put('problemas_resueltos_$hoy', actual + 1);
  }

  Future<bool> _puedeResolverHoy() async {
    final resueltos = await _obtenerProblemasResueltosHoy();
    return resueltos < 5;
  }

  Future<void> _verificarInstruccionesDelDia() async {
    final box = await Hive.openBox('configuracion');
    final ultimaFecha = box.get('ultima_instruccion_matematicas');
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    if (ultimaFecha != hoy) {
      _mostrarInstrucciones();
      await box.put('ultima_instruccion_matematicas', hoy);
    }
  }

  void _mostrarInstrucciones() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Icon(Icons.calculate, color: AppTheme.verde, size: 40),
            const SizedBox(height: 8),
            const Text('📚 Matemáticas de Negocios', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.verde)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🧠 Debes estar preparado para esta sección retadora.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text('Podrás hacerlo mental y, conforme avances, podrás apoyarte de papel y lápiz.', style: TextStyle(fontSize: 14))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade300)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚠️ Solo hay una regla sumamente estricta:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('❌ No podrás usar tecnología (sin calculadora, sin IA)', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade300)),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(child: Text('📅 Puedes resolver hasta 5 problemas por día.', style: TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('✅ Acepto el reto', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensajeLimiteDiario() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
            const SizedBox(height: 8),
            const Text('🎉 ¡Excelente trabajo, Lombrikid!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.verde)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
              child: const Text('🌟 ¡Has completado tus 5 problemas de hoy!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.verde), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            const Text('Recuerda: aprender poco a poco es mejor que hacerlo todo de golpe.\n\n¡Descansa y vuelve mañana para más desafíos! 🌱', textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('¡Vale, volveré mañana!', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _cargarProblemas() {
    _todosLosProblemas.addAll([
      ProblemaMatematico(id: 'base_1', nivel: 'base', pregunta: 'En una caja hay 18 lombrices y en otra hay 24. ¿Cuántas lombrices hay en total?', respuestaCorrecta: '42', opciones: ['38', '42', '44', '48'], monedasGanadas: 2, emoji: '➕'),
      ProblemaMatematico(id: 'base_2', nivel: 'base', pregunta: 'En un lombricario había 60 lombrices. Si regalaron 18, ¿cuántas quedaron?', respuestaCorrecta: '42', opciones: ['38', '42', '44', '48'], monedasGanadas: 2, emoji: '➖'),
      ProblemaMatematico(id: 'base_3', nivel: 'base', pregunta: 'Cada caja tiene 30 lombrices. Si hay 7 cajas, ¿cuántas lombrices hay en total?', respuestaCorrecta: '210', opciones: ['180', '200', '210', '240'], monedasGanadas: 2, emoji: '✖️'),
      ProblemaMatematico(id: 'base_4', nivel: 'base', pregunta: 'Una lombriz produce 2 gramos de humus por semana. Si hay 25 lombrices, ¿cuántos gramos de humus producen en una semana?', respuestaCorrecta: '50', opciones: ['40', '50', '60', '75'], monedasGanadas: 2, emoji: '🧮'),
      ProblemaMatematico(id: 'base_5', nivel: 'base', pregunta: 'Si una bolsa de humus pesa 5 kg y se llenan 8 bolsas, ¿cuántos kilogramos de humus hay en total?', respuestaCorrecta: '40', opciones: ['30', '35', '40', '45'], monedasGanadas: 2, emoji: '⚖️'),
      ProblemaMatematico(id: 'base_6', nivel: 'base', pregunta: 'En el huerto se usaron 36 kg de humus y quedaban 52 kg almacenados. ¿Cuántos kilogramos había al principio?', respuestaCorrecta: '88', opciones: ['78', '82', '88', '96'], monedasGanadas: 2, emoji: '📦'),
      ProblemaMatematico(id: 'base_7', nivel: 'base', pregunta: 'Un grupo de estudiantes recolectó 48 cáscaras de frutas. Si las repartieron en 6 cajas para las lombrices, ¿cuántas cáscaras pusieron en cada caja?', respuestaCorrecta: '8', opciones: ['6', '7', '8', '9'], monedasGanadas: 2, emoji: '➗'),
      ProblemaMatematico(id: 'base_8', nivel: 'base', pregunta: 'Hay 54 lombrices y se quieren repartir por igual en 9 recipientes. ¿Cuántas lombrices habrá en cada recipiente?', respuestaCorrecta: '6', opciones: ['4', '5', '6', '7'], monedasGanadas: 2, emoji: '📦'),

      ProblemaMatematico(id: 'bronce_1', nivel: 'bronce', pregunta: 'Una familia separó 4 kg de residuos orgánicos cada día durante 7 días. ¿Cuántos kilogramos separaron en total?', respuestaCorrecta: '28', opciones: ['24', '26', '28', '32'], monedasGanadas: 3, emoji: '🗑️'),
      ProblemaMatematico(id: 'bronce_2', nivel: 'bronce', pregunta: 'Si una bolsa de humus cuesta \$35 y una persona compra 4 bolsas, ¿cuánto debe pagar?', respuestaCorrecta: '140', opciones: ['120', '130', '140', '150'], monedasGanadas: 3, emoji: '💰'),
      ProblemaMatematico(id: 'bronce_3', nivel: 'bronce', pregunta: 'Una escuela vendió 9 bolsas de humus a \$40 cada una. ¿Cuánto dinero obtuvo?', respuestaCorrecta: '360', opciones: ['320', '340', '360', '400'], monedasGanadas: 3, emoji: '🏫'),
      ProblemaMatematico(id: 'bronce_4', nivel: 'bronce', pregunta: 'En un taller participaron 32 niños. Si se formaron equipos de 4 integrantes, ¿cuántos equipos se hicieron?', respuestaCorrecta: '8', opciones: ['6', '7', '8', '9'], monedasGanadas: 3, emoji: '👥'),
      ProblemaMatematico(id: 'bronce_5', nivel: 'bronce', pregunta: 'Una lombriz mide aproximadamente 8 cm. Si colocas 6 lombrices una tras otra, ¿cuántos centímetros medirían en total?', respuestaCorrecta: '48', opciones: ['40', '42', '46', '48'], monedasGanadas: 3, emoji: '📏'),
      ProblemaMatematico(id: 'bronce_6', nivel: 'bronce', pregunta: 'Se recolectaron 72 hojas secas y se repartieron en 8 montones iguales. ¿Cuántas hojas quedaron en cada montón?', respuestaCorrecta: '9', opciones: ['7', '8', '9', '10'], monedasGanadas: 3, emoji: '🍂'),
      ProblemaMatematico(id: 'bronce_7', nivel: 'bronce', pregunta: 'Si cada planta necesita 2 puños de humus y hay 18 plantas, ¿cuántos puños de humus se necesitan?', respuestaCorrecta: '36', opciones: ['30', '32', '34', '36'], monedasGanadas: 3, emoji: '🌱'),
      ProblemaMatematico(id: 'bronce_8', nivel: 'bronce', pregunta: 'En una semana nacieron 40 lombrices nuevas. Si ya había 125, ¿cuántas hay ahora?', respuestaCorrecta: '165', opciones: ['155', '160', '165', '170'], monedasGanadas: 3, emoji: '🪱'),

      ProblemaMatematico(id: 'plata_1', nivel: 'plata', pregunta: 'Se prepararon 10 cajas para lombrices y en cada una se colocaron 15 lombrices. ¿Cuántas lombrices se utilizaron?', respuestaCorrecta: '150', opciones: ['140', '145', '150', '160'], monedasGanadas: 4, emoji: '📦'),
      ProblemaMatematico(id: 'plata_2', nivel: 'plata', pregunta: 'Si un kilogramo de humus cuesta \$28 y una persona compra 6 kg, ¿cuánto pagará?', respuestaCorrecta: '168', opciones: ['148', '158', '168', '178'], monedasGanadas: 4, emoji: '💰'),
      ProblemaMatematico(id: 'plata_3', nivel: 'plata', pregunta: 'En un huerto había 96 plantas. Si se abonaron primero 58, ¿cuántas plantas faltan por abonar?', respuestaCorrecta: '38', opciones: ['28', '32', '38', '42'], monedasGanadas: 4, emoji: '🌿'),
      ProblemaMatematico(id: 'plata_4', nivel: 'plata', pregunta: 'En el criadero hay 8 cajas con 25 lombrices cada una. ¿Cuántas lombrices hay en total?', respuestaCorrecta: '200', opciones: ['180', '190', '200', '220'], monedasGanadas: 4, emoji: '🏠'),
      ProblemaMatematico(id: 'plata_5', nivel: 'plata', pregunta: 'Si una lombriz cuesta \$1.50 y un cliente compra 6, ¿cuánto debe pagar?', respuestaCorrecta: '9.00', opciones: ['7.50', '8.00', '9.00', '10.50'], monedasGanadas: 4, emoji: '🪱'),
      ProblemaMatematico(id: 'plata_6', nivel: 'plata', pregunta: 'Se vendieron 15 lombrices a \$1.50 cada una. ¿Cuánto dinero se obtuvo?', respuestaCorrecta: '22.50', opciones: ['18.50', '20.00', '22.50', '24.00'], monedasGanadas: 4, emoji: '💰'),
      ProblemaMatematico(id: 'plata_7', nivel: 'plata', pregunta: 'Hay 240 lombrices y se quieren repartir en 8 cajas con la misma cantidad. ¿Cuántas lombrices irán en cada caja?', respuestaCorrecta: '30', opciones: ['25', '28', '30', '32'], monedasGanadas: 4, emoji: '📦'),
      ProblemaMatematico(id: 'plata_8', nivel: 'plata', pregunta: 'Se tienen 180 lombrices y cada cliente compra 12. ¿A cuántos clientes se les puede vender?', respuestaCorrecta: '15', opciones: ['12', '13', '14', '15'], monedasGanadas: 4, emoji: '👥'),

      ProblemaMatematico(id: 'oro_1', nivel: 'oro', pregunta: 'Una lombriz cuesta \$1.50. ¿Cuánto costarán 28 lombrices?', respuestaCorrecta: '42.00', opciones: ['36.00', '40.00', '42.00', '48.00'], monedasGanadas: 5, emoji: '💎'),
      ProblemaMatematico(id: 'oro_2', nivel: 'oro', pregunta: 'Si 20 lombrices cuestan \$30, ¿cuánto costarán 45 lombrices si el precio por lombriz es el mismo?', respuestaCorrecta: '67.50', opciones: ['60.00', '65.00', '67.50', '72.00'], monedasGanadas: 5, emoji: '🧮'),
      ProblemaMatematico(id: 'oro_3', nivel: 'oro', pregunta: 'En una semana se vendieron 120 lombrices. Si cada una costó \$0.50, ¿cuál fue el ingreso total?', respuestaCorrecta: '60.00', opciones: ['50.00', '55.00', '60.00', '65.00'], monedasGanadas: 5, emoji: '🏪'),
      ProblemaMatematico(id: 'oro_4', nivel: 'oro', pregunta: 'Un criadero tenía 500 lombrices. Vendió 175 y después nacieron 80 más. ¿Cuántas lombrices tiene ahora?', respuestaCorrecta: '405', opciones: ['385', '395', '405', '415'], monedasGanadas: 5, emoji: '🏠'),
      ProblemaMatematico(id: 'oro_5', nivel: 'oro', pregunta: 'Si 20 lombrices cuestan \$30, ¿cuánto costarán 50 lombrices?', respuestaCorrecta: '75.00', opciones: ['65.00', '70.00', '75.00', '80.00'], monedasGanadas: 5, emoji: '💰'),
      ProblemaMatematico(id: 'oro_6', nivel: 'oro', pregunta: 'Si 80 lombrices cuestan \$120, ¿cuánto costarán 150 lombrices?', respuestaCorrecta: '225.00', opciones: ['200.00', '210.00', '225.00', '240.00'], monedasGanadas: 5, emoji: '🧮'),
      ProblemaMatematico(id: 'oro_7', nivel: 'oro', pregunta: 'Un cliente compró 40 lombrices por \$60. Si otro cliente quiere 75 lombrices, ¿cuánto deberá pagar?', respuestaCorrecta: '112.50', opciones: ['100.00', '105.00', '112.50', '120.00'], monedasGanadas: 5, emoji: '🪱'),
      ProblemaMatematico(id: 'oro_8', nivel: 'oro', pregunta: 'Si con 100 lombrices se pueden iniciar 4 camas de lombricomposta, ¿cuántas camas se pueden iniciar con 250 lombrices?', respuestaCorrecta: '10', opciones: ['8', '9', '10', '12'], monedasGanadas: 5, emoji: '🏆'),
    ]);
  }

  Color _getColorNivel(String nivel) {
    switch (nivel) {
      case 'base': return Colors.green;
      case 'bronce': return Colors.brown;
      case 'plata': return Colors.grey;
      case 'oro': return Colors.amber;
      default: return AppTheme.verde;
    }
  }

  String _getEmojiNivel(String nivel) {
    switch (nivel) {
      case 'base': return '🌱';
      case 'bronce': return '🥉';
      case 'plata': return '🥈';
      case 'oro': return '🥇';
      default: return '⭐';
    }
  }

  String _getNombreNivel(String nivel) {
    switch (nivel) {
      case 'base': return 'Base';
      case 'bronce': return 'Bronce';
      case 'plata': return 'Plata';
      case 'oro': return 'Oro';
      default: return '';
    }
  }

  void _seleccionarNivel(String nivel) {
    setState(() {
      _nivelSeleccionado = nivel;
      _problemaActualIndex = 0;
      _puntaje = 0;
      _monedasGanadas = 0;
      _mostrarResultado = false;
      _problemaRespondido = false;
    });
  }

  void _responderOpcion(String opcionSeleccionada) async {
    if (_problemaRespondido) return;

    final puedeResolver = await _puedeResolverHoy();
    if (!puedeResolver) {
      _mostrarMensajeLimiteDiario();
      return;
    }

    final problema = _problemasFiltrados[_problemaActualIndex];
    final bool esCorrecto = opcionSeleccionada == problema.respuestaCorrecta;

    setState(() {
      _problemaRespondido = true;
      if (esCorrecto) {
        _puntaje++;
        _monedasGanadas += problema.monedasGanadas;
        _mensajeFeedback = '🎉 ¡Correcto! +${problema.monedasGanadas} monedas';
        _colorFeedback = AppTheme.verde;
      } else {
        _mensajeFeedback = '😅 La correcta era: ${problema.respuestaCorrecta}';
        _colorFeedback = Colors.red;
      }
    });

    if (esCorrecto) {
      await _guardarProblemaResueltoHoy();
      // ✅ Usar agregarMonedas (ya usa el box inicializado)
      await MonedasService().agregarMonedas(problema.monedasGanadas);
      await _cargarMonedasActuales();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _problemaRespondido = false;
        if (_problemaActualIndex < _problemasFiltrados.length - 1) {
          _problemaActualIndex++;
        } else {
          _mostrarResultado = true;
          _guardarMonedasGanadas();
        }
      });
    });
  }

  void _guardarMonedasGanadas() async {
    if (_monedasGanadas > 0) {
      try {
        // ✅ Usar agregarMonedas en lugar de guardar directamente
        await MonedasService().agregarMonedas(_monedasGanadas);
        await _cargarMonedasActuales();
        _actividadService.registrarActividad();
      } catch (e) {
        print('Error guardando monedas: $e');
      }
    }
  }

  void _reiniciarNivel() {
    setState(() {
      _problemaActualIndex = 0;
      _puntaje = 0;
      _monedasGanadas = 0;
      _mostrarResultado = false;
      _problemaRespondido = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧮 Matemáticas de Negocios'),
        backgroundColor: AppTheme.verde,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$_monedasActuales', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNivelButton('base', '🌱', 'Base'),
                    _buildNivelButton('bronce', '🥉', 'Bronce'),
                    _buildNivelButton('plata', '🥈', 'Plata'),
                    _buildNivelButton('oro', '🥇', 'Oro'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<int>(
                future: _obtenerProblemasResueltosHoy(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final resueltos = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppTheme.verde),
                          const SizedBox(width: 8),
                          Text('📚 Problemas de hoy: ', style: const TextStyle(fontSize: 13)),
                          Text('$resueltos/5', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: resueltos >= 5 ? Colors.amber : AppTheme.verde)),
                          if (resueltos >= 5) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: Colors.amber, size: 16)],
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _mostrarResultado
                    ? SingleChildScrollView(child: _buildResultado())
                    : SingleChildScrollView(child: _buildProblema(isSmallScreen)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNivelButton(String nivel, String emoji, String label) {
    final isSelected = _nivelSeleccionado == nivel;
    final color = _getColorNivel(nivel);
    return GestureDetector(
      onTap: () => _seleccionarNivel(nivel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildProblema(bool isSmallScreen) {
    final problemas = _problemasFiltrados;
    if (problemas.isEmpty) {
      return const Center(child: Text('No hay problemas en este nivel'));
    }
    final problema = problemas[_problemaActualIndex];
    final total = problemas.length;
    final progreso = ((_problemaActualIndex + 1) / total * 100);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_getEmojiNivel(_nivelSeleccionado)} ${_getNombreNivel(_nivelSeleccionado)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 16)),
              Text('${_problemaActualIndex + 1} / $total', style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 12 : 14)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progreso / 100,
            backgroundColor: Colors.grey.shade200,
            color: _getColorNivel(_nivelSeleccionado),
            minHeight: 4,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 14),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
            decoration: BoxDecoration(
              color: AppTheme.verde.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.verde.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(problema.emoji, style: TextStyle(fontSize: isSmallScreen ? 22 : 28)),
                const SizedBox(width: 10),
                Expanded(child: Text(problema.pregunta, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, height: 1.3))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...problema.opciones.map((opcion) {
            bool isCorrect = opcion == problema.respuestaCorrecta;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: _problemaRespondido ? null : () => _responderOpcion(opcion),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 14, vertical: isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: _problemaRespondido
                        ? (isCorrect ? AppTheme.verde.withOpacity(0.12) : Colors.red.withOpacity(0.08))
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _problemaRespondido ? (isCorrect ? AppTheme.verde : Colors.red) : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _problemaRespondido ? (isCorrect ? AppTheme.verde : Colors.red) : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + problema.opciones.indexOf(opcion)),
                            style: TextStyle(
                              color: _problemaRespondido ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(opcion, style: TextStyle(fontSize: isSmallScreen ? 13 : 15))),
                      if (_problemaRespondido && isCorrect) const Icon(Icons.check_circle, color: AppTheme.verde, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          if (_problemaRespondido)
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: _colorFeedback.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _colorFeedback.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(_colorFeedback == AppTheme.verde ? Icons.check_circle : Icons.cancel, color: _colorFeedback, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_mensajeFeedback, style: TextStyle(color: _colorFeedback, fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 12 : 14))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultado() {
    final total = _problemasFiltrados.length;
    final aciertos = _puntaje;
    final porcentaje = total > 0 ? (aciertos / total * 100).round() : 0;

    String mensajeFinal;
    IconData iconoFinal;
    Color colorFinal;

    if (porcentaje == 100) {
      mensajeFinal = '🎉 ¡Excelente! Resolviste todos correctamente';
      iconoFinal = Icons.emoji_events;
      colorFinal = Colors.amber;
    } else if (porcentaje >= 70) {
      mensajeFinal = '😊 ¡Muy bien! Sigue practicando';
      iconoFinal = Icons.star;
      colorFinal = AppTheme.verde;
    } else if (porcentaje >= 50) {
      mensajeFinal = '🤔 ¡Buen intento! Revisa los errores y vuelve a intentar';
      iconoFinal = Icons.school;
      colorFinal = Colors.orange;
    } else {
      mensajeFinal = '💪 ¡No te rindas! Practica más y lo lograrás';
      iconoFinal = Icons.favorite;
      colorFinal = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconoFinal, size: 60, color: colorFinal),
          const SizedBox(height: 10),
          const Text('¡Nivel completado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${_getEmojiNivel(_nivelSeleccionado)} ${_getNombreNivel(_nivelSeleccionado)}', style: TextStyle(fontSize: 16, color: _getColorNivel(_nivelSeleccionado), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$aciertos / $total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: colorFinal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorFinal.withOpacity(0.3)),
                ),
                child: Text('$porcentaje%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorFinal)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(mensajeFinal, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text('+$_monedasGanadas monedas', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _reiniciarNivel,
                style: ElevatedButton.styleFrom(backgroundColor: _getColorNivel(_nivelSeleccionado), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), minimumSize: const Size(80, 40)),
                child: const Text('🔄 Repetir'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verdeClaro, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), minimumSize: const Size(80, 40)),
                child: const Text('⬅️ Volver'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}