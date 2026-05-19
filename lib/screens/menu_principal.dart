import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/logros_service.dart';
import '../services/actividad_service.dart';
import 'chat_ia.dart';
import 'diario/mi_composta.dart';
import 'diario/nueva_entrada.dart';
import 'juegos/clasifica_residuos.dart';
import 'juegos/alimenta_lola.dart';
import 'juegos/memorama.dart';
import 'tienda/catalogo.dart';
import 'logros.dart';
import 'modulo_educativo.dart';
import 'max_crecimiento.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  final LogrosService _logrosService = LogrosService();
  final ActividadService _actividadService = ActividadService();
  int _categoriaAbierta = -1;
  int _estrellas = 0;

  @override
  void initState() {
    super.initState();
    _actividadService.registrarActividad();
    _estrellas = _logrosService.obtenerEstrellas();
  }

  // ============ MÉTODOS AUXILIARES ============

  void _irAPantalla(Widget pantalla) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  Widget _buildPersonajes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.verde.withValues(alpha: 0.1), AppTheme.azulCielo.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.verde.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniPersonaje('🪱', 'Lola'),
          _buildMiniPersonaje('🪱', 'Lalo'),
          _buildMiniPersonaje('🪣', 'Don\nCompostín'),
          _buildMiniPersonaje('🌳', 'Max\nManzanero'),
        ],
      ),
    );
  }

  Widget _buildMiniPersonaje(String emoji, String nombre) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.cafe),
        ),
      ],
    );
  }

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
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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

  // ============ BUILD PRINCIPAL ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Hola, Eco Héroe! 🪱'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text('$_estrellas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MaxCrecimientoScreen()),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPersonajes(),

              const SizedBox(height: 16),

              _buildCategoria(
                titulo: '📚 Aprendizaje',
                color: AppTheme.verde,
                index: 0,
                opciones: [
                  _buildOpcion('Conoce a las lombrices', 'Aprende sobre Lola y Lalo', Icons.bug_report,
                    () => _irAPantalla(const ModuloEducativoScreen(
                      titulo: '🪱 Conoce a las lombrices',
                      descripcion: 'Las lombrices son pequeñas pero poderosas aliadas del planeta.',
                      informacion: 'Las lombrices californianas son las mejores para hacer composta...',
                      puntosClave: [
                        {'emoji': '🪱', 'titulo': 'Lombriz californiana', 'descripcion': 'La especie ideal para compostaje'},
                        {'emoji': '🌍', 'titulo': 'Viven en la tierra', 'descripcion': 'Necesitan humedad y oscuridad'},
                        {'emoji': '🍎', 'titulo': 'Qué comen', 'descripcion': 'Restos de frutas, verduras y café'},
                      ],
                    )),
                  ),
                  _buildOpcion('¿Qué es la lombricomposta?', 'Beneficios y proceso', Icons.recycling, () {}),
                  _buildOpcion('Aprende a hacerla', 'Paso a paso en casa', Icons.construction, () {}),
                ],
              ),

              _buildCategoria(
                titulo: '🎮 Juegos',
                color: AppTheme.azulCielo,
                index: 1,
                opciones: [
                  _buildOpcion('♻️ Clasifica residuos', 'Arrastra al contenedor correcto', Icons.recycling,
                      () => _irAPantalla(const ClasificaResiduosScreen())),
                  _buildOpcion('🪱 Alimenta a Lola', 'Dale comida buena', Icons.restaurant,
                      () => _irAPantalla(const AlimentaLolaScreen())),
                  _buildOpcion('🧠 Memorama', 'Encuentra las parejas', Icons.memory,
                      () => _irAPantalla(const MemoramaScreen())),
                ],
              ),

              _buildCategoria(
                titulo: '📸 Mi Composta',
                color: AppTheme.amarillo,
                index: 2,
                opciones: [
                  _buildOpcion('📷 Ver diario', 'Línea de tiempo y fotos', Icons.photo_library,
                      () => _irAPantalla(const MiCompostaScreen())),
                  _buildOpcion('➕ Nueva entrada', 'Registra tu avance', Icons.add_a_photo,
                      () => _irAPantalla(const NuevaEntradaScreen())),
                  _buildOpcion('💬 Pregúntale a Lola', 'Chat educativo', Icons.chat,
                      () => _irAPantalla(const ChatIAScreen())),
                ],
              ),

              _buildCategoria(
                titulo: '🛒 Tienda',
                color: AppTheme.cafe,
                index: 3,
                opciones: [
                  _buildOpcion('🪱 Kit de composta', 'Compra tu kit básico', Icons.shopping_cart,
                      () => _irAPantalla(const TiendaScreen())),
                  _buildOpcion('📦 Mis productos', 'Ver carrito', Icons.inventory_2, () {}),
                ],
              ),

              _buildCategoria(
                titulo: '⭐ Progreso',
                color: AppTheme.verde,
                index: 4,
                opciones: [
                  _buildOpcion('🏆 Mis logros', 'Insignias y medallas', Icons.emoji_events,
                      () => _irAPantalla(const LogrosScreen())),
                  _buildOpcion('📜 Certificados', 'Tus reconocimientos', Icons.workspace_premium, () {}),
                  _buildOpcion('👥 Invitar amigos', 'Comparte la app', Icons.group_add, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Próximamente! 🚧')),
                    );
                  }),
                ],
              ),

              // Indicador de Max
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.verde.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.verde.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe_right, color: AppTheme.verde),
                    SizedBox(width: 8),
                    Text(
                      'Desliza → para ver a Max Manzanero 🌳',
                      style: TextStyle(color: AppTheme.verde, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}