import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/theme.dart';
import '../../services/accesorios_service.dart';
import '../../services/monedas_service.dart';
import '../../models/accesorio.dart';

class ConfigAccesorio {
  final double top;
  final double right;
  final double width;

  const ConfigAccesorio({required this.top, required this.right, required this.width});
}

final Map<String, ConfigAccesorio> coordenadasAccesorios = {
  'gorra_azul_pluma': const ConfigAccesorio(top: -10, right: 10, width: 70),
  'gorra_balon': const ConfigAccesorio(top: -3, right: 15, width: 70),
  'gorra_futbol_lentes': const ConfigAccesorio(top: -10, right: 10, width: 70),
  'gorra_futbol_sinta': const ConfigAccesorio(top: -10, right: 10, width: 70),
  'gorra_lentes_oscuros': const ConfigAccesorio(top: -3, right: 15, width: 70),
  'gorra_lombriz': const ConfigAccesorio(top: -13, right: 15, width: 70),
  'gorra_parches_amarilla': const ConfigAccesorio(top: -3, right: 15, width: 70),
  'gorra_parches_azul': const ConfigAccesorio(top: -5, right: 11, width: 70),
  'gorra_parches_futbol': const ConfigAccesorio(top: -5, right: 10, width: 70),
  'gorra_parches_gris': const ConfigAccesorio(top: -5, right: 11, width: 70),
  'gorra_parches_militar': const ConfigAccesorio(top: -3, right: 12, width: 70),
  'lentes_azules': const ConfigAccesorio(top: 10, right: 26, width: 60),
  'lentes_descanso': const ConfigAccesorio(top: 15, right: 25, width: 60),
  'lentes_futbol': const ConfigAccesorio(top: 12, right: 23, width: 80),
  'lentes_inventor': const ConfigAccesorio(top: 17, right: 29, width: 65),
  'lentes_militares': const ConfigAccesorio(top: 16, right: 25, width: 60),
  'lentes_naranjas': const ConfigAccesorio(top: 15, right: 25, width: 60),
  'lentes_oscuros': const ConfigAccesorio(top: 19, right: 28, width: 60),
  'lentes_simples': const ConfigAccesorio(top: 4, right: 25, width: 65),
  'lentes_sol': const ConfigAccesorio(top: 15, right: 31, width: 60),
  'collar_perlas_amarillas': const ConfigAccesorio(top: 48, right: 20, width: 60),
  'collar_perlas': const ConfigAccesorio(top: 55, right: 20, width: 60),
  'collar_plateado_pluma': const ConfigAccesorio(top: 55, right: 20, width: 60),
  'collar_pluma': const ConfigAccesorio(top: 55, right: 20, width: 60),
  'sombrero_amarillo': const ConfigAccesorio(top: -25, right: 20, width: 65),
  'sombrero_arcoiris': const ConfigAccesorio(top: -25, right: 20, width: 65),
  'sombrero_azul': const ConfigAccesorio(top: -25, right: 20, width: 65),
  'sombrero_estilo_flores': const ConfigAccesorio(top: -25, right: 20, width: 65),
  'sombrero_estilo_morado': const ConfigAccesorio(top: -25, right: 20, width: 65),
  'sombrero_estilo_naranja': const ConfigAccesorio(top: -25, right: 20, width: 65),
  'sombrero_rojo': const ConfigAccesorio(top: -20, right: 20, width: 65),
  'sombrero_verde': const ConfigAccesorio(top: -25, right: 20, width: 65),
};

class AccesoriosScreen extends StatefulWidget {
  const AccesoriosScreen({super.key});

  @override
  State<AccesoriosScreen> createState() => _AccesoriosScreenState();
}

class _AccesoriosScreenState extends State<AccesoriosScreen> {
  late AccesoriosService _accesoriosService;
  late MonedasService _monedasService;

  List<Accesorio> _accesorios = [];
  int _monedas = 0;
  bool _isLoading = true;

  final List<String> _categorias = ['Gorras', 'Lentes', 'Collares', 'Sombreros'];
  String _categoriaSeleccionada = 'Gorras';
  String _personaje = 'Lombriz';

  // ✅ Variables para la prueba de accesorios
  Accesorio? _accesorioEnPrueba;
  bool _modoPrueba = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      _accesoriosService = AccesoriosService();
      await _accesoriosService.init();

      _monedasService = MonedasService();
      await _monedasService.init();

      _monedas = _monedasService.obtenerMonedas();

      final configBox = await Hive.openBox('configuracion');
      _personaje = configBox.get('personaje', defaultValue: 'Lombriz');

      _cargarAccesorios();

    } catch (e) {
      print('Error cargando datos: $e');
    }

    setState(() => _isLoading = false);
  }

  void _cargarAccesorios() {
    final List<Accesorio> todosLosAccesorios = [
      Accesorio(id: 'gorra_azul_pluma', nombre: 'Gorra Azul con Pluma', imagen: 'assets/images/accesorios/gorra_azul_pluma.png', precio: 25),
      Accesorio(id: 'gorra_balon', nombre: 'Gorra Balón', imagen: 'assets/images/accesorios/gorra_balon.png', precio: 20),
      Accesorio(id: 'gorra_futbol_lentes', nombre: 'Gorra Fútbol con Lentes', imagen: 'assets/images/accesorios/gorra_futbol_lentes.png', precio: 30),
      Accesorio(id: 'gorra_futbol_sinta', nombre: 'Gorra Fútbol con Sinta', imagen: 'assets/images/accesorios/gorra_futbol_sinta.png', precio: 28),
      Accesorio(id: 'gorra_lentes_oscuros', nombre: 'Gorra con Lentes Oscuros', imagen: 'assets/images/accesorios/gorra_lentes_oscuros.png', precio: 35),
      Accesorio(id: 'gorra_lombriz', nombre: 'Gorra Lombriz', imagen: 'assets/images/accesorios/gorra_lombriz.png', precio: 20),
      Accesorio(id: 'gorra_parches_amarilla', nombre: 'Gorra Parches Amarilla', imagen: 'assets/images/accesorios/gorra_parches_amarilla.png', precio: 25),
      Accesorio(id: 'gorra_parches_azul', nombre: 'Gorra Parches Azul', imagen: 'assets/images/accesorios/gorra_parches_azul.png', precio: 25),
      Accesorio(id: 'gorra_parches_futbol', nombre: 'Gorra Parches Fútbol', imagen: 'assets/images/accesorios/gorra_parches_futbol.png', precio: 28),
      Accesorio(id: 'gorra_parches_gris', nombre: 'Gorra Parches Gris', imagen: 'assets/images/accesorios/gorra_parches_gris.png', precio: 25),
      Accesorio(id: 'gorra_parches_militar', nombre: 'Gorra Parches Militar', imagen: 'assets/images/accesorios/gorra_parches_militar.png', precio: 30),

      Accesorio(id: 'lentes_azules', nombre: 'Lentes Azules', imagen: 'assets/images/accesorios/lentes_azules.png', precio: 30),
      Accesorio(id: 'lentes_descanso', nombre: 'Lentes de Descanso', imagen: 'assets/images/accesorios/lentes_descanso.png', precio: 25),
      Accesorio(id: 'lentes_futbol', nombre: 'Lentes Fútbol', imagen: 'assets/images/accesorios/lentes_futbol.png', precio: 28),
      Accesorio(id: 'lentes_inventor', nombre: 'Lentes de Inventor', imagen: 'assets/images/accesorios/lentes_inventor.png', precio: 35),
      Accesorio(id: 'lentes_militares', nombre: 'Lentes Militares', imagen: 'assets/images/accesorios/lentes_militares.png', precio: 32),
      Accesorio(id: 'lentes_naranjas', nombre: 'Lentes Naranjas', imagen: 'assets/images/accesorios/lentes_naranjas.png', precio: 30),
      Accesorio(id: 'lentes_oscuros', nombre: 'Lentes Oscuros', imagen: 'assets/images/accesorios/lentes_oscuros.png', precio: 35),
      Accesorio(id: 'lentes_simples', nombre: 'Lentes Simples', imagen: 'assets/images/accesorios/lentes_simples.png', precio: 20),
      Accesorio(id: 'lentes_sol', nombre: 'Lentes de Sol', imagen: 'assets/images/accesorios/lentes_sol.png', precio: 30),

      Accesorio(id: 'collar_perlas_amarillas', nombre: 'Collar Perlas Amarillas', imagen: 'assets/images/accesorios/collar_perlas_amarillas.png', precio: 45),
      Accesorio(id: 'collar_perlas', nombre: 'Collar de Perlas', imagen: 'assets/images/accesorios/collar_perlas.png', precio: 40),
      Accesorio(id: 'collar_plateado_pluma', nombre: 'Collar Plateado con Pluma', imagen: 'assets/images/accesorios/collar_plateado_pluma.png', precio: 50),
      Accesorio(id: 'collar_pluma', nombre: 'Collar con Pluma', imagen: 'assets/images/accesorios/collar_pluma.png', precio: 35),

      Accesorio(id: 'sombrero_amarillo', nombre: 'Sombrero Amarillo', imagen: 'assets/images/accesorios/sombrero_amarillo.png', precio: 35),
      Accesorio(id: 'sombrero_arcoiris', nombre: 'Sombrero Arcoíris', imagen: 'assets/images/accesorios/sombrero_arcoiris.png', precio: 40),
      Accesorio(id: 'sombrero_azul', nombre: 'Sombrero Azul', imagen: 'assets/images/accesorios/sombrero_azul.png', precio: 35),
      Accesorio(id: 'sombrero_estilo_flores', nombre: 'Sombrero Estilo Flores', imagen: 'assets/images/accesorios/sombrero_estilo_flores.png', precio: 45),
      Accesorio(id: 'sombrero_estilo_morado', nombre: 'Sombrero Estilo Morado', imagen: 'assets/images/accesorios/sombrero_estilo_morado.png', precio: 45),
      Accesorio(id: 'sombrero_estilo_naranja', nombre: 'Sombrero Estilo Naranja', imagen: 'assets/images/accesorios/sombrero_estilo_naranja.png', precio: 45),
      Accesorio(id: 'sombrero_rojo', nombre: 'Sombrero Rojo', imagen: 'assets/images/accesorios/sombrero_rojo.png', precio: 35),
      Accesorio(id: 'sombrero_verde', nombre: 'Sombrero Verde', imagen: 'assets/images/accesorios/sombrero_verde.png', precio: 35),
    ];

    String prefijo = '';
    switch (_categoriaSeleccionada) {
      case 'Gorras': prefijo = 'gorra'; break;
      case 'Lentes': prefijo = 'lentes'; break;
      case 'Collares': prefijo = 'collar'; break;
      case 'Sombreros': prefijo = 'sombrero'; break;
    }

    final accesoriosFiltrados = todosLosAccesorios
        .where((a) => a.id.startsWith(prefijo))
        .toList();

    final comprados = _accesoriosService.obtenerComprados(_personaje);
    final equipados = _accesoriosService.obtenerEquipados(_personaje);

    for (var accesorio in accesoriosFiltrados) {
      accesorio.comprado = comprados.contains(accesorio.id);

      if (equipados['gorra'] == accesorio.id ||
          equipados['lentes'] == accesorio.id ||
          equipados['collar'] == accesorio.id ||
          equipados['sombrero'] == accesorio.id) {
        accesorio.equipado = true;
      }
    }

    setState(() {
      _accesorios = accesoriosFiltrados;
    });
  }

  // ✅ Método para probar un accesorio
  void _probarAccesorio(Accesorio accesorio) {
    setState(() {
      _accesorioEnPrueba = accesorio;
      _modoPrueba = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('👀 Probando: ${accesorio.nombre}'),
        backgroundColor: AppTheme.verde,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ✅ Método para quitar la prueba
  void _quitarPrueba() {
    setState(() {
      _accesorioEnPrueba = null;
      _modoPrueba = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔙 Prueba finalizada'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildPersonajeConAccesorios() {
    final equipados = _accesoriosService.obtenerEquipados(_personaje);

    // ✅ Si estamos en modo prueba, mostrar el accesorio en prueba
    String? gorra = equipados['gorra'];
    String? lentes = equipados['lentes'];
    String? collar = equipados['collar'];
    String? sombrero = equipados['sombrero'];

    if (_modoPrueba && _accesorioEnPrueba != null) {
      final id = _accesorioEnPrueba!.id;
      if (id.startsWith('gorra')) {
        gorra = id;
        sombrero = null; // Excluir sombrero si se prueba una gorra
      } else if (id.startsWith('lentes')) {
        lentes = id;
      } else if (id.startsWith('collar')) {
        collar = id;
      } else if (id.startsWith('sombrero')) {
        sombrero = id;
        gorra = null; // Excluir gorra si se prueba un sombrero
      }
    }

    return Container(
      height: 180,
      width: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/personaje/lombriz_base.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          if (collar != null)
            Positioned(
              top: coordenadasAccesorios[collar]?.top ?? 18,
              right: coordenadasAccesorios[collar]?.right ?? 100,
              child: Image.asset(
                'assets/images/accesorios/$collar.png',
                width: coordenadasAccesorios[collar]?.width ?? 50,
              ),
            ),
          if (lentes != null)
            Positioned(
              top: coordenadasAccesorios[lentes]?.top ?? 10,
              right: coordenadasAccesorios[lentes]?.right ?? 30,
              child: Image.asset(
                'assets/images/accesorios/$lentes.png',
                width: coordenadasAccesorios[lentes]?.width ?? 58,
              ),
            ),
          if (gorra != null)
            Positioned(
              top: coordenadasAccesorios[gorra]?.top ?? -5,
              right: coordenadasAccesorios[gorra]?.right ?? 22,
              child: Image.asset(
                'assets/images/accesorios/$gorra.png',
                width: coordenadasAccesorios[gorra]?.width ?? 65,
              ),
            ),
          if (sombrero != null)
            Positioned(
              top: coordenadasAccesorios[sombrero]?.top ?? -5,
              right: coordenadasAccesorios[sombrero]?.right ?? 33,
              child: Image.asset(
                'assets/images/accesorios/$sombrero.png',
                width: coordenadasAccesorios[sombrero]?.width ?? 65,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _comprarAccesorio(Accesorio accesorio) async {
    if (accesorio.comprado) {
      _equiparAccesorio(accesorio);
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🛒 Comprar ${accesorio.nombre}'),
        content: Text(
          '¿Quieres comprar ${accesorio.nombre} por ${accesorio.precio} monedas?\n\n'
          '💰 Monedas disponibles: $_monedas',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verde,
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final exito = await _accesoriosService.comprarAccesorio(
      _personaje,
      accesorio.id,
      accesorio.precio,
    );

    if (exito) {
      setState(() {
        accesorio.comprado = true;
        _monedas = _monedasService.obtenerMonedas();
        // ✅ Si estábamos probando, quitamos el modo prueba
        if (_modoPrueba && _accesorioEnPrueba?.id == accesorio.id) {
          _modoPrueba = false;
          _accesorioEnPrueba = null;
        }
      });

      _equiparAccesorio(accesorio);
    }
  }

  void _equiparAccesorio(Accesorio accesorio) async {
    final equipados = _accesoriosService.obtenerEquipados(_personaje);

    String categoria;
    if (accesorio.id.startsWith('gorra')) categoria = 'gorra';
    else if (accesorio.id.startsWith('lentes')) categoria = 'lentes';
    else if (accesorio.id.startsWith('collar')) categoria = 'collar';
    else if (accesorio.id.startsWith('sombrero')) categoria = 'sombrero';
    else return;

    if (equipados[categoria] == accesorio.id) {
      await _accesoriosService.equiparAccesorio(
        _personaje,
        categoria == 'gorra' ? null : equipados['gorra'],
        categoria == 'lentes' ? null : equipados['lentes'],
        categoria == 'collar' ? null : equipados['collar'],
        categoria == 'sombrero' ? null : equipados['sombrero'],
      );

      setState(() {
        accesorio.equipado = false;
        _cargarAccesorios();
      });
      return;
    }

    if (categoria == 'gorra' && equipados['sombrero'] != null) {
      _mostrarAlertaConflicto('No puedes equipar una gorra si ya tienes un sombrero puesto. ¡Quítatelo primero!');
      return;
    }

    if (categoria == 'sombrero' && equipados['gorra'] != null) {
      _mostrarAlertaConflicto('No puedes equipar un sombrero si ya tienes una gorra puesta. ¡Quítatela primero!');
      return;
    }

    String? nuevaGorra = equipados['gorra'];
    String? nuevaLentes = equipados['lentes'];
    String? nuevaCollar = equipados['collar'];
    String? nuevaSombrero = equipados['sombrero'];

    if (categoria == 'gorra') {
      nuevaGorra = accesorio.id;
      nuevaSombrero = null;
    }
    else if (categoria == 'lentes') nuevaLentes = accesorio.id;
    else if (categoria == 'collar') nuevaCollar = accesorio.id;
    else if (categoria == 'sombrero') {
      nuevaSombrero = accesorio.id;
      nuevaGorra = null;
    }

    await _accesoriosService.equiparAccesorio(
      _personaje,
      nuevaGorra,
      nuevaLentes,
      nuevaCollar,
      nuevaSombrero,
    );

    setState(() {
      accesorio.equipado = true;
      // ✅ Si estábamos probando, quitamos el modo prueba
      if (_modoPrueba) {
        _modoPrueba = false;
        _accesorioEnPrueba = null;
      }
      _cargarAccesorios();
    });
  }

  void _mostrarAlertaConflicto(String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('¡Atención!'),
          ],
        ),
        content: Text(
          mensaje,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verde,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Tienda de Accesorios'),
        backgroundColor: AppTheme.verde,
        actions: [
          if (_modoPrueba)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _quitarPrueba,
              tooltip: 'Quitar prueba',
            ),
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
                Text(
                  '$_monedas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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
        child: Column(
          children: [
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Column(
                  children: [
                    _buildPersonajeConAccesorios(),
                    // ✅ Indicador de modo prueba
                    if (_modoPrueba && _accesorioEnPrueba != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Probando: ${_accesorioEnPrueba!.nombre}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    final seleccionada = _categoriaSeleccionada == categoria;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categoriaSeleccionada = categoria;
                          // ✅ Quitar prueba al cambiar de categoría
                          if (_modoPrueba) _quitarPrueba();
                          _cargarAccesorios();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: seleccionada ? AppTheme.verde : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                            color: seleccionada ? Colors.white : Colors.grey.shade600,
                            fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _accesorios.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay accesorios en esta categoría',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _accesorios.length,
                          itemBuilder: (context, index) {
                            final accesorio = _accesorios[index];
                            return _buildAccesorioCard(accesorio);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesorioCard(Accesorio accesorio) {
    final enPrueba = _modoPrueba && _accesorioEnPrueba?.id == accesorio.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: enPrueba
            ? Border.all(color: Colors.amber, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: enPrueba
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: enPrueba ? Colors.amber.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              accesorio.imagen,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.shopping_bag,
                  size: 30,
                  color: Colors.grey.shade400,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accesorio.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accesorio.comprado
                      ? (accesorio.equipado ? '✅ Equipado' : 'Disponible')
                      : '💰 ${accesorio.precio} monedas',
                  style: TextStyle(
                    fontSize: 13,
                    color: accesorio.equipado
                        ? AppTheme.verde
                        : (accesorio.comprado
                            ? Colors.blue
                            : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          // ✅ Botón de Probar (solo si NO está comprado)
          if (!accesorio.comprado && !enPrueba)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                onPressed: () => _probarAccesorio(accesorio),
                icon: const Icon(Icons.visibility, color: Colors.amber),
                tooltip: 'Probar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.amber.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          // ✅ Botón de Quitar prueba
          if (enPrueba)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                onPressed: _quitarPrueba,
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Quitar prueba',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => _comprarAccesorio(accesorio),
            style: ElevatedButton.styleFrom(
              backgroundColor: accesorio.comprado
                  ? (accesorio.equipado ? Colors.grey : AppTheme.verde)
                  : AppTheme.verde,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(80, 36),
            ),
            child: Text(
              accesorio.comprado
                  ? (accesorio.equipado ? 'Quitar' : 'Equipar')
                  : 'Comprar',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}