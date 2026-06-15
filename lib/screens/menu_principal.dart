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
// import 'tienda/catalogo.dart';  // 🟡 COMENTADO - Tienda (pendiente para futuro)
// import 'tienda/tienda_accesorios.dart';  // 🟡 COMENTADO - Tienda accesorios (pendiente)
// import 'historial_monedas.dart';  // 🟡 COMENTADO - Historial monedas (pendiente)
import 'logros.dart';
import 'modulo_educativo.dart';
// import 'tienda/tienda_accesorios.dart';  // 🟡 COMENTADO - Tienda accesorios (pendiente)
// import 'historial_monedas.dart';  // 🟡 COMENTADO - Historial monedas (pendiente)
import '../services/recordatorios_service.dart';
import 'recordatorios.dart';
import 'avisos.dart';
import 'perfil_screen.dart';
import 'admin_screen.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final LogrosService _logrosService = LogrosService();
  final ActividadService _actividadService = ActividadService();
  // final MonedasService _monedasService = MonedasService();  // 🟡 COMENTADO - Monedas (pendiente)
  // final AccesoriosService _accesoriosService = AccesoriosService();  // 🟡 COMENTADO - Accesorios (pendiente)
  
  int _categoriaAbierta = -1;
  int _contadorToques = 0;
  // int _estrellas = 0;  // 🟡 COMENTADO - Estrellas (pendiente)
  // int _monedas = 0;  // 🟡 COMENTADO - Monedas (pendiente)
  
  // // Accesorios equipados (pendiente para futuro)
  // String? _gorraEquipada;
  // String? _lentesEquipados;
  // String? _collarEquipado;
  // String? _sombreroEquipado;

  @override
  void initState() {
    super.initState();
    // _cargarDatos();  // 🟡 COMENTADO - Pendiente para cuando se active tienda
    _actividadService.registrarActividad();
    // _estrellas = _logrosService.obtenerEstrellas();  // 🟡 COMENTADO - Estrellas (pendiente)
    _verificarRecordatorios();
  }

  // 🟡 COMENTADO - Pendiente para cuando se active tienda
  // Future<void> _cargarDatos() async {
  //   await _monedasService.init();
  //   await _accesoriosService.init();
  //   
  //   final monedas = _monedasService.obtenerMonedas();
  //   final configBox = await Hive.openBox('configuracion');
  //   final genero = configBox.get('usuario_genero', defaultValue: 'Lola');
  //   final equipados = _accesoriosService.obtenerEquipados(genero);
  //   
  //   setState(() {
  //     _monedas = monedas;
  //     _gorraEquipada = equipados['gorra'];
  //     _lentesEquipados = equipados['lentes'];
  //     _collarEquipado = equipados['collar'];
  //     _sombreroEquipado = equipados['sombrero'];
  //   });
  // }

  void _verificarRecordatorios() {
    final service = RecordatoriosService();
    if (service.hayPendientes()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final pendientes = service.obtenerPendientes();
        if (pendientes.isNotEmpty) {
          _mostrarAlertaRecordatorio(pendientes.first);
        }
      });
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

  // ✅ Método para abrir panel admin (oculto)
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

    // ✅ Área táctil para abrir panel admin (al tocar el título)
  Widget _buildTituloAdmin() {
      return GestureDetector(
        onTap: _abrirPanelAdmin,
        // He añadido alignment para asegurar que el texto y la imagen grande
        // queden centrados verticalmente entre sí.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Centrado vertical
          children: [
            const Text(
              '¡Hola, Lombikid!',
              // He subido un poco el tamaño de letra (de 20 a 22) 
              // para que no se vea tan pequeña al lado de la imagen grande.
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12), // Un poco más de espacio ahora que es más grande
            
            // --- AQUÍ ESTÁ TU LOMBRIZ MÁS GRANDE ---
            Image.asset(
              'assets/images/logo_lombriaventura.png', 
              height: 50, // <-- Cambia este número para ajustar el tamaño
              fit: BoxFit.contain,
              
              errorBuilder: (context, error, stackTrace) {
                // Si la imagen falla, el emoji también sube de tamaño para no verse ridículo
                return const Text('🪱', style: TextStyle(fontSize: 40)); 
            },
          ),
        ],
      ),
    );
  }

  // 🟡 COMENTADO - Personajes (pendiente para cuando se active)
  // Widget _buildPersonajes() {
  //   return Container(...);
  // }

  // 🟡 COMENTADO - Personaje con accesorios (pendiente)
  // Widget _buildPersonajeConAccesorios(String nombre, double size) {
  //   return Column(...);
  // }

  // 🟡 COMENTADO - Mini personaje emoji (pendiente)
  // Widget _buildMiniPersonajeEmoji(String emoji, String nombre) {
  //   return Column(...);
  // }

  Widget _buildCategoria({
    required String titulo,
    required Color color,
    required int index,
    required List<Widget> opciones,
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: abierta ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: abierta ? color : Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Fredoka',
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: abierta ? 0.5 : 0,
                    child: Icon(Icons.keyboard_arrow_down, color: color),
                  ),
                ],
              ),
            ),
            if (abierta)
              Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(children: opciones),
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
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.verde, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitulo, style: const TextStyle(fontSize: 11, color: AppTheme.cafe)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.cafe),
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
          // 🟡 COMENTADO - Monedas y estrellas (pendiente para futuro)
          // Padding(
          //   padding: const EdgeInsets.only(right: 8),
          //   child: Row(
          //     children: [
          //       const Icon(Icons.star, color: Colors.amber, size: 20),
          //       const SizedBox(width: 4),
          //       Text('$_estrellas', style: const TextStyle(fontSize: 16)),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 12),
          //   child: Row(
          //     children: [
          //       const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          //       const SizedBox(width: 4),
          //       Text('$_monedas', style: const TextStyle(fontSize: 16)),
          //     ],
          //   ),
          // ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _irAPantalla(const PerfilScreen()),
            tooltip: 'Mi perfil',
          ),
        ],
        backgroundColor: AppTheme.verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🟡 COMENTADO - Personajes (pendiente para cuando se active)
            // _buildPersonajes(),
            // const SizedBox(height: 16),
            
            // ==================== APRENDIZAJE ====================
            _buildCategoria(
              titulo: '📚 Aprendizaje',
              color: AppTheme.verde,
              index: 0,
              opciones: [
                _buildOpcion('Conoce a las lombrices', 'Aprende sobre Lola y Lalo', Icons.bug_report,
                  () => _irAPantalla(ModuloEducativoScreen(
                    titulo: '🪱 Conoce a las lombrices',
                    descripcion: 'Las lombrices son pequeñas pero poderosas aliadas del planeta.',
                    informacion: '🐛 ¡Hola! Soy Lola, una lombriz roja californiana. '
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
              color: AppTheme.amarillo,
              index: 1,
              opciones: [
                _buildOpcion('📷 Ver diario', 'Línea de tiempo y fotos', Icons.photo_library,
                    () => _irAPantalla(const MiCompostaScreen())),
                _buildOpcion('📓 Mi diario', 'Registra tu avance', Icons.edit_note,
                    () => _irAPantalla(const NuevaEntradaScreen())),
                _buildOpcion('🎮 Clasifica residuos', 'Juega y aprende', Icons.recycling,
                    () => _irAPantalla(const ClasificaResiduosScreen())),
                _buildOpcion('🎮 Alimenta a Lola', 'Cuida a tu lombriz', Icons.restaurant,
                    () => _irAPantalla(const AlimentaLolaScreen())),
                _buildOpcion('🎮 Memorama ecológico', 'Encuentra las parejas', Icons.memory,
                    () => _irAPantalla(const MemoramaScreen())),
                _buildMenuButton('Pregúntale a Lola 🤖', Icons.chat, AppTheme.azulCielo,
                    () => _irAPantalla(const ChatIAScreen())),
                _buildOpcion('⚠️ Avisos importantes', 'Cuida a tus lombrices', Icons.warning_amber,
                    () => _irAPantalla(const AvisosScreen())),
              ],
            ),
            
            // 🟡 COMENTADO - TIENDA (pendiente para futuro)
            // _buildCategoria(
            //   titulo: '🛒 Tienda',
            //   color: AppTheme.cafe,
            //   index: 2,
            //   opciones: [
            //     _buildOpcion('🪱 Kit de composta', 'Compra tu kit básico', Icons.shopping_cart,
            //         () => _irAPantalla(const TiendaScreen())),
            //     _buildOpcion('🛍️ Accesorios', 'Compra para Lola y Lalo', Icons.store,
            //         () => _irAPantalla(const TiendaAccesoriosScreen())),
            //     _buildOpcion('📜 Mis monedas', 'Tus monedas ganadas', Icons.monetization_on,
            //         () => _irAPantalla(const HistorialMonedasScreen())),
            //   ],
            // ),
            
            // ==================== PROGRESO ====================
            _buildCategoria(
              titulo: '⭐ Progreso',
              color: AppTheme.verde,
              index: 2,  // 🟡 Índice ajustado (antes era 4, ahora 2)
              opciones: [
                _buildOpcion('🏆 Mis logros', 'Insignias y medallas', Icons.emoji_events,
                    () => _irAPantalla(const LogrosScreen())),
                // 🟡 COMENTADO - Historial (no implementado)
                // _buildOpcion('📜 Historial', 'Ver tu progreso', Icons.history, () {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Próximamente 🚧')),
                //     );
                //   }),
                _buildOpcion('⏰ Recordatorios', 'Alertas y cuidados', Icons.notifications_active,
                    () => _irAPantalla(const RecordatoriosScreen())),
              ],
            ),
            
            // ==================== MI NEGOCIO REAL ====================
            _buildCategoria(
              titulo: '💼 Mi negocio real',
              color: Colors.orange,
              index: 3,  // 🟡 Índice ajustado (antes era 5, ahora 3)
              opciones: [
                _buildOpcion('🪱 Vender lombrices', 'Precio: \$2.50 c/u', Icons.sell,
                    () => _irAPantalla(const VentasLombricesScreen())),
                _buildOpcion('💧 Atomizador lixiviado', 'Precio: \$25', Icons.water_drop,
                    () => _irAPantalla(const VentasAtomizadorScreen())),
                _buildOpcion('🌱 Vender humus', 'Precio: \$10/kg', Icons.agriculture,
                    () => _irAPantalla(const VentasHumusScreen())),
                _buildOpcion('📊 Registro de ventas', 'Historial de ingresos', Icons.receipt,
                    () => _irAPantalla(const VentasHistorialScreen())),
                _buildOpcion('🎓 Capacitación', 'Capacita a otros niños', Icons.school,
                    () => _irAPantalla(const CapacitacionScreen())),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}