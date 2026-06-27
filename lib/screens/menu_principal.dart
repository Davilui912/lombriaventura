import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/theme.dart';
import '../services/logros_service.dart';
import '../services/actividad_service.dart';
import '../services/monedas_service.dart';
import '../services/accesorios_service.dart';
import '../widgets/personaje_con_accesorios.dart';
import 'chat_ia_screen.dart';
import 'diario/mi_composta.dart';
import 'diario/nueva_entrada.dart';
import 'juegos/clasifica_residuos.dart';
import 'juegos/alimenta_lola.dart';
import 'tienda/ventas_lombrices.dart';
import 'tienda/ventas_atomizador.dart';
import 'tienda/ventas_historial.dart';
import 'tienda/ventas_humus.dart';
import 'tienda/capacitacion.dart';
import 'juegos/memorama.dart';
import 'logros.dart';
import 'modulo_educativo.dart';
import '../services/retos_service.dart'; 
import 'recordatorios.dart';
import 'avisos.dart';
import 'tienda/problemas_matematicos.dart';  
import 'perfil_screen.dart';
import 'admin_screen.dart';
import 'retos_screen.dart';
import '../services/recordatorios_service.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final LogrosService _logrosService = LogrosService();
  final ActividadService _actividadService = ActividadService();
  
  int _categoriaAbierta = -1;
  int _contadorToques = 0;
  bool _mostrarBanner = true;

  @override
  void initState() {
    super.initState();
    _actividadService.registrarActividad();
    
    //  Esperar 3 segundos antes de verificar recordatorios
    Future.delayed(const Duration(seconds: 3), () {
      _verificarRecordatorios();
    });
    
    _inicializarRecordatorios();
  }

  Future<void> _inicializarRecordatorios() async {
    //  Verificar si el Reto 1 está completado antes de activar recordatorios
    final retosService = RetosService();
    await retosService.init();
    
    if (retosService.estaCompletadoReto1()) {
      final recordatorioService = RecordatoriosService();
      await recordatorioService.init();
      recordatorioService.programarRecordatorioDiario();
      recordatorioService.programarRecordatorioLixiviado();
    }
  }
  
  void _verificarRecordatorios() async {
    //  Verificar si el Reto 1 está completado antes de mostrar recordatorios
    final retosService = RetosService();
    await retosService.init();
    
    if (!retosService.estaCompletadoReto1()) return;
    
    final service = RecordatoriosService();
    await service.init();
    if (service.hayPendientes()) {
      final pendientes = service.obtenerPendientes();
      if (pendientes.isNotEmpty && mounted) {
        _mostrarAlertaRecordatorio(pendientes.first);
      }
    }
  }

  void _mostrarAlertaRecordatorio(Map<String, dynamic> rec) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(rec['icono'], style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 10),
            Expanded(child: Text(rec['titulo'], style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(rec['mensaje'], style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              RecordatoriosService().marcarVisto(rec['id']);
              Navigator.pop(ctx);
            },
            child: const Text('✅ ¡Hecho!'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecordatoriosScreen()),
              );
            },
            child: const Text('Ver todos 📋'),
          ),
        ],
      ),
    );
  }

  void _irAPantalla(Widget pantalla) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  void _abrirPanelAdmin() {
    _contadorToques++;
    if (_contadorToques >= 5) {
      _contadorToques = 0;
      _irAPantalla(const AdminScreen());
    }
    Future.delayed(const Duration(seconds: 3), () {
      _contadorToques = 0;
    });
  }

  Widget _buildTituloAdmin() {
    return GestureDetector(
      onTap: _abrirPanelAdmin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '¡Hola, Lombrikid!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/logo_lombriaventura.png',
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text('🪱', style: TextStyle(fontSize: 40));
            },
          ),
        ],
      ),
    );
  }
  Widget _buildSubmenuJuegos() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.azulCielo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.azulCielo.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.azulCielo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.games, color: AppTheme.azulCielo, size: 20),
          ),
          title: const Text(
            '🎮 Juegos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.azulCielo,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: AppTheme.azulCielo),
          children: [
            _buildOpcion('♻️ Clasifica residuos', 'Juega y aprende', Icons.recycling, 
                () => _irAPantalla(const ClasificaResiduosScreen())),
            _buildOpcion('🪱 Alimenta a Lola', 'Cuida a tu lombriz', Icons.restaurant, 
                () => _irAPantalla(const AlimentaLolaScreen())),
            _buildOpcion('🧠 Memorama ecológico', 'Encuentra las parejas', Icons.memory, 
                () => _irAPantalla(const MemoramaScreen())),
          ],
        ),
      ),
    );
  }
  Widget _buildSubmenu({
    required String titulo,
    required IconData icon,
    required Color color,
    required List<Widget> opciones,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              children: opciones,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCategoria({
    required String titulo,
    required String subtitulo,
    required Color color,
    required Color color2,
    required int index,
    required List<Widget> opciones,
    IconData? icon,
    String? iconImage,
  }) {
    final abierta = _categoriaAbierta == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _categoriaAbierta = abierta ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color, color2],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: iconImage != null
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              iconImage,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  icon ?? Icons.help_outline,
                                  color: Colors.white,
                                  size: 34,
                                );
                              },
                            ),
                          )
                        : Icon(
                            icon ?? Icons.help_outline,
                            color: Colors.white,
                            size: 34,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: abierta ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            if (abierta)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: opciones,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcion(String titulo, String subtitulo, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.verde, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.negro,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppTheme.verde,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.cafe),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTituloAdmin(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _irAPantalla(const PerfilScreen()),
            tooltip: 'Mi perfil',
          ),
        ],
        backgroundColor: AppTheme.verde,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ==================== APRENDIZAJE ====================
                    _buildCategoria(
                      titulo: 'Aprendizaje',
                      subtitulo: 'Descubre y aprende',
                      color: const Color(0xFF43A047),
                      color2: const Color(0xFF66BB6A),
                      iconImage: 'assets/images/icons/icono_aprendizaje.png',
                      index: 0,
                      opciones: [
                        _buildOpcion('Conoce a las lombrices', 'Aprende sobre Lola y Lalo', Icons.bug_report,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '🪱 Conoce a las lombrices',
                            descripcion: 'Las lombrices son pequeñas pero poderosas aliadas del planeta.',
                            informacion: '🐛 ¡Hola! Soy la lombriz sabia, una lombriz roja californiana. '
                                'Somos las mejores para hacer composta porque comemos muy rápido.\n\n'
                                '🌱 ¿CÓMO NACEMOS?\n'
                                'Nos juntamos en pareja y compartimos una parte de nuestro cuerpo. '
                                'Ponemos huevitos dentro de capullos ¡Cada 10 días! De cada capullo '
                                'pueden nacer entre 2 y 5 lombrices bebés. Las bebés tardan 2 o 3 '
                                'meses en ser adultas (lo sabrás cuando veas un anillo en nuestro cuerpo).\n\n'
                                '🍎 ¿QUÉ COMEMOS? (¡ATENCIÓN!)\n'
                                'NO comemos residuos frescos. Tienen que esperar unos días a que '
                                'se fermenten. Nos encanta: cáscaras de frutas/verduras EN TROZOS '
                                'PEQUEÑOS, restos de café, hojas secas, cartón mojado, '
                                'cáscara de huevo triturada.\n\n'
                                '🚫 ¡NUNCA NOS DES! Carnes, huesos, lácteos, cítricos en exceso, '
                                'sal, aceites, plásticos. Eso nos enferma o nos puede matar.\n\n'
                                '🏠 NUESTRO HOGAR PERFECTO\n'
                                '• Temperatura: 15°C - 25°C (sin frío ni calor extremos)\n'
                                '• Humedad: como una esponja escurrida (prueba del puño)\n'
                                '• Un recipiente con drenaje para que salga el lixiviado\n'
                                '• Malla para que no entren moscas\n\n'
                                '💧 ¿QUÉ ES EL LIXIVIADO?\n'
                                'Es el líquido que sale de la composta. ¡Es súper nutritivo! '
                                'Se mezcla con 10 partes de agua y se echa a las plantas. '
                                'Cuidado: el lixiviado de la basura común SÍ es tóxico, por eso '
                                'separamos los residuos.\n\n'
                                '🌟 ¿SABÍAS QUÉ?\n'
                                '• No tenemos dientes, por eso corta nuestra comida chiquita\n'
                                '• Podemos comer la mitad de nuestro peso cada día\n'
                                '• Ayudamos a reducir la basura que contamina el agua y el suelo',
                            puntosClave: [
                              {'emoji': '🪱', 'titulo': 'Lombriz californiana', 'descripcion': 'La especie ideal para compostaje, come su peso en un día'},
                              {'emoji': '🌍', 'titulo': 'Viven en la tierra', 'descripcion': 'Necesitan humedad y oscuridad para sobrevivir'},
                              {'emoji': '🍎', 'titulo': 'Qué comen', 'descripcion': 'Restos de frutas, verduras, cáscaras de huevo y café'},
                              {'emoji': '✨', 'titulo': 'Beneficios', 'descripcion': 'Producen humus, el mejor fertilizante natural'},
                            ],
                          )),
                        ),
                        _buildOpcion('¿Qué es la lombricomposta?', 'Beneficios y proceso', Icons.recycling,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '♻️ ¿Qué es la lombricomposta?',
                            descripcion: 'La lombricomposta es un abono natural creado por lombrices que transforman residuos orgánicos en el mejor fertilizante para las plantas.',
                            informacion: 'La lombricomposta, también llamada vermicomposta, es el resultado de la descomposición de residuos orgánicos por lombrices californianas. '
                                'Estas lombrices comen los restos de comida y los convierten en humus, un abono rico en nutrientes.\n\n'
                                'Es 100% natural, no contamina y ayuda a reducir la basura que va a los tiraderos.',
                            puntosClave: [
                              {'emoji': '🪱', 'titulo': 'Hecho por lombrices', 'descripcion': 'Las lombrices californianas son las protagonistas'},
                              {'emoji': '🌱', 'titulo': 'Abono natural', 'descripcion': 'Aporta nitrógeno, fósforo y potasio a las plantas'},
                              {'emoji': '♻️', 'titulo': 'Cero contaminación', 'descripcion': 'Reduce hasta 50% de basura orgánica en casa'},
                              {'emoji': '💧', 'titulo': 'Produce lixiviado', 'descripcion': 'Un líquido nutritivo para regar plantas'},
                            ],
                          )),
                        ),
                        _buildOpcion('Aprende a hacerla', 'Paso a paso en casa', Icons.construction,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '🛠️ Aprende a hacerla',
                            descripcion: 'Crear tu propia lombricomposta es muy fácil. Solo necesitas seguir estos pasos y tener paciencia.',
                            informacion: 'Puedes hacer lombricomposta de dos formas:\n\n'
                                'Opción 1: Con estiércol de animales herbívoros (conejo, vaca, caballo).\n'
                                'Opción 2: Con residuos de cocina (cáscaras, restos de frutas y verduras).\n\n'
                                'En ambos casos necesitas un contenedor con agujeros para ventilación, tierra, fibra de coco y lombrices californianas.',
                            puntosClave: [
                              {'emoji': '📦', 'titulo': '1. Prepara el contenedor', 'descripcion': 'Haz agujeros para que respiren las lombrices'},
                              {'emoji': '🥥', 'titulo': '2. Agrega sustrato', 'descripcion': 'Fibra de coco y tierra húmeda como cama'},
                              {'emoji': '🪱', 'titulo': '3. Coloca las lombrices', 'descripcion': 'Ponlas sobre la cama y deja que se adapten'},
                              {'emoji': '🍎', 'titulo': '4. Añade residuos', 'descripcion': 'Cáscaras de frutas, verduras y restos de café'},
                              {'emoji': '💧', 'titulo': '5. Mantén la humedad', 'descripcion': 'Rocía agua para que esté húmedo, no empapado'},
                              {'emoji': '⏳', 'titulo': '6. Espera 2-3 meses', 'descripcion': 'Cosecha el humus cuando esté oscuro y suave'},
                            ],
                          )),
                        ),
                        _buildOpcion('Materiales necesarios', 'Lo que ocupas para empezar', Icons.list_alt,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '📋 Materiales necesarios',
                            descripcion: 'No necesitas muchas cosas para empezar tu lombricomposta. ¡Seguro ya tienes varias en casa!',
                            informacion: 'Los materiales básicos son económicos y fáciles de conseguir. '
                                'Lo más importante son las lombrices californianas, que son diferentes a las lombrices de jardín.',
                            puntosClave: [
                              {'emoji': '📦', 'titulo': 'Contenedor', 'descripcion': 'De plástico o madera, con agujeros para ventilación'},
                              {'emoji': '🪱', 'titulo': 'Lombrices californianas', 'descripcion': 'Las mejores para composta, comen su peso en un día'},
                              {'emoji': '🥥', 'titulo': 'Fibra de coco', 'descripcion': 'Sirve como cama y retiene humedad'},
                              {'emoji': '🪨', 'titulo': 'Tierra', 'descripcion': 'Tierra de jardín o composta como base'},
                              {'emoji': '🍂', 'titulo': 'Material seco', 'descripcion': 'Hojas secas, cartón sin tinta, aserrín (carbono)'},
                              {'emoji': '🍎', 'titulo': 'Residuos orgánicos', 'descripcion': 'Cáscaras, restos de frutas y verduras (nitrógeno)'},
                            ],
                          )),
                        ),
                        _buildOpcion('Balance 80/20', 'Nitrógeno y carbono', Icons.balance,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '⚖️ Balance 80/20',
                            descripcion: 'Para una composta saludable necesitas equilibrar materiales verdes (nitrógeno) y materiales secos (carbono).',
                            informacion: 'La regla es 80% material seco (carbono) y 20% material verde (nitrógeno).\n\n'
                                'Demasiado nitrógeno = mal olor y moscas.\n'
                                'Demasiado carbono = proceso muy lento.\n\n'
                                'El equilibrio perfecto hace felices a las lombrices y produce el mejor humus.',
                            puntosClave: [
                              {'emoji': '🍂', 'titulo': '80% CARBONO (seco)', 'descripcion': 'Hojas secas, cartón, aserrín, papel sin tinta'},
                              {'emoji': '🍎', 'titulo': '20% NITRÓGENO (verde)', 'descripcion': 'Cáscaras, restos de frutas, verduras, café'},
                              {'emoji': '👃', 'titulo': '¿Huele mal?', 'descripcion': 'Agrega más material seco (carbono)'},
                              {'emoji': '🐌', 'titulo': '¿Muy lento?', 'descripcion': 'Agrega más material verde (nitrógeno)'},
                            ],
                          )),
                        ),
                        _buildOpcion('Lixiviado', 'El oro líquido de la composta', Icons.water_drop,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '💧 Lixiviado',
                            descripcion: 'El lixiviado es un líquido oscuro que se produce durante la lombricomposta. ¡Es oro líquido para tus plantas!',
                            informacion: 'El lixiviado es el exceso de agua que escurre de la composta cargado de nutrientes.\n\n'
                                'Se recolecta en la parte baja del contenedor y se diluye en agua para regar plantas.\n\n'
                                'Proporción: 1 parte de lixiviado por 10 partes de agua.',
                            puntosClave: [
                              {'emoji': '💧', 'titulo': '¿Qué es?', 'descripcion': 'Líquido rico en nutrientes que escurre de la composta'},
                              {'emoji': '🪣', 'titulo': 'Recolecta', 'descripcion': 'Usa un contenedor con llave en la parte inferior'},
                              {'emoji': '🧪', 'titulo': 'Diluye', 'descripcion': '1 taza de lixiviado por 10 tazas de agua'},
                              {'emoji': '🌻', 'titulo': 'Usa en plantas', 'descripcion': 'Riega tus macetas y jardín con esta mezcla'},
                            ],
                          )),
                        ),
                        _buildOpcion('Cuidados', 'Mantén felices a tus lombrices', Icons.favorite,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '💚 Cuidados',
                            descripcion: 'Las lombrices son seres vivos que necesitan cuidados básicos. ¡No te preocupes, es muy sencillo!',
                            informacion: 'Los 3 cuidados esenciales:\n\n'
                                '1. HUMEDAD: La composta debe estar húmeda como una esponja exprimida.\n'
                                '2. TEMPERATURA: Entre 15°C y 25°C, protegidas del sol directo.\n'
                                '3. ALIMENTACIÓN: Una vez por semana, en pequeñas cantidades.',
                            puntosClave: [
                              {'emoji': '💧', 'titulo': 'Humedad ideal', 'descripcion': 'Como esponja exprimida. Rocía agua si está seco'},
                              {'emoji': '🌡️', 'titulo': 'Temperatura', 'descripcion': '15-25°C. No exponer al sol directo ni frío extremo'},
                              {'emoji': '🍎', 'titulo': 'Alimentación', 'descripcion': '1 vez por semana. Pica los residuos en trozos pequeños'},
                              {'emoji': '🚫', 'titulo': 'NO dar', 'descripcion': 'Carne, lácteos, cítricos en exceso, cebolla, ajo, plástico'},
                            ],
                          )),
                        ),
                        _buildOpcion('Emprendimiento', 'Gana dinero ayudando al planeta', Icons.monetization_on,
                          () => _irAPantalla(ModuloEducativoScreen(
                            titulo: '💰 Emprendimiento',
                            descripcion: '¿Sabías que puedes ganar dinero con tu lombricomposta? ¡Aprende a vender y ayudar al planeta!',
                            informacion: 'Puedes vender:\n\n'
                                '• Composta (humus): \$50-100 MXN por kilo\n'
                                '• Lixiviado: \$30-50 MXN por litro\n'
                                '• Lombrices: \$100-200 MXN por 100 lombrices\n\n'
                                'Ideal para vender en tu escuela, colonia o redes sociales.',
                            puntosClave: [
                              {'emoji': '🛍️', 'titulo': 'Vende composta', 'descripcion': 'Empaca en bolsas de 1kg y vende a vecinos y jardineros'},
                              {'emoji': '🧴', 'titulo': 'Vende lixiviado', 'descripcion': 'Embasa en botellas recicladas como fertilizante líquido'},
                              {'emoji': '🪱', 'titulo': 'Vende lombrices', 'descripcion': 'Cuando tengas muchas, separa y vende paquetes'},
                              {'emoji': '📱', 'titulo': 'Promoción', 'descripcion': 'Toma fotos bonitas y comparte en WhatsApp o Facebook'},
                            ],
                          )),
                        ),
                      ],
                    ),
                    // ==================== MI COMPOSTA ====================  
                    _buildCategoria(
                      titulo: '📸 Mi Composta',
                      subtitulo: 'Cuida tu composta',
                      color: const Color(0xFFFFA726),
                      color2: const Color(0xFFFFCA28),
                      iconImage: 'assets/images/icons/icono_composta.png',
                      index: 1,
                      opciones: [
                        _buildOpcion('📓 Mi diario', 'Registra tu avance', Icons.edit_note, 
                            () => _irAPantalla(const NuevaEntradaScreen())),
                        
                        _buildMenuButton('Pregúntale a la lombriz sabia 🤖', Icons.chat, AppTheme.azulCielo, 
                            () => _irAPantalla(const ChatIAScreen())),
                        
                        _buildOpcion('⚠️ Avisos importantes', 'Cuida a tus lombrices', Icons.warning_amber, 
                            () => _irAPantalla(const AvisosScreen())),
                        
                        // ✅ Submenú de juegos (desplegable)
                        _buildSubmenuJuegos(),
                      ],
                    ),
                    // ==================== PROGRESO ====================
                    _buildCategoria(
                      titulo: 'Progreso',
                      subtitulo: 'Revisa tus logros',
                      color: const Color(0xFF42A5F5),
                      color2: const Color(0xFF64B5F6),
                      iconImage: 'assets/images/icons/icono_progreso.png',
                      index: 2,
                      opciones: [
                        _buildOpcion('🏆 Mis logros', 'Insignias y medallas', Icons.emoji_events, () => _irAPantalla(const LogrosScreen())),
                        _buildOpcion('🎯 Retos', 'Completa los desafíos', Icons.flag, () => _irAPantalla(const RetosScreen())),
                        _buildOpcion('⏰ Recordatorios', 'Alertas y cuidados', Icons.notifications_active, () => _irAPantalla(const RecordatoriosScreen())),
                      ],
                    ),
                    // ==================== MI NEGOCIO REAL ====================
                    _buildCategoria(
                      titulo: 'Mi negocio real',
                      subtitulo: 'Vende y capacita',
                      color: const Color(0xFFFF7043),
                      color2: const Color(0xFFFF8A65),
                      iconImage: 'assets/images/icons/icono_negocio.png',
                      index: 3,
                      opciones: [
                        _buildOpcion('🪱 Vender lombrices', 'Precio: \$2.50 c/u', Icons.sell, () => _irAPantalla(const VentasLombricesScreen())),
                        _buildOpcion('💧 Atomizador lixiviado', 'Precio: \$25', Icons.water_drop, () => _irAPantalla(const VentasAtomizadorScreen())),
                        _buildOpcion('🌱 Vender humus', 'Precio: \$10 por bolsita', Icons.agriculture, () => _irAPantalla(const VentasHumusScreen())),
                        _buildOpcion('📊 Registro de ventas', 'Historial de ingresos', Icons.receipt, () => _irAPantalla(const VentasHistorialScreen())),
                        _buildOpcion('🎓 Capacitación', 'Capacita a otros niños', Icons.school, () => _irAPantalla(const CapacitacionScreen())),
                        _buildOpcion('🧮 Problemas matemáticos', 'Gana monedas resolviendo', Icons.calculate, () => _irAPantalla(const ProblemasMatematicosScreen())),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // ✅ Banner promocional fijo al final
            if (_mostrarBanner)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/banner_promocional.png',
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.verde, AppTheme.verdeClaro],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '🌟 ¡Descubre más en Lombriaventura!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mostrarBanner = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}