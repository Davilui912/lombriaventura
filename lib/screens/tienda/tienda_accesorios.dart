import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';
import '../../services/accesorios_service.dart';
import '../../widgets/personaje_con_accesorios.dart';

class TiendaAccesoriosScreen extends StatefulWidget {
  const TiendaAccesoriosScreen({super.key});

  @override
  State<TiendaAccesoriosScreen> createState() => _TiendaAccesoriosScreenState();
}

class _TiendaAccesoriosScreenState extends State<TiendaAccesoriosScreen> {
  final MonedasService _monedasService = MonedasService();
  final AccesoriosService _accesoriosService = AccesoriosService();
  
  int _monedas = 0;
  final String _personajeActual = 'Lola';
  
  final List<AccesorioItem> _accesorios = [
    AccesorioItem(id: 'gorra_azul_pluma', nombre: 'Gorra Azul con Pluma', tipo: 'gorra', imagen: 'gorra_azul_pluma.png', precio: 50),
    AccesorioItem(id: 'gorra_balon', nombre: 'Gorra de Balón', tipo: 'gorra', imagen: 'gorra_balon.png', precio: 45),
    AccesorioItem(id: 'gorra_futbol_lentes', nombre: 'Gorra Fútbol con Lentes', tipo: 'gorra', imagen: 'gorra_futbol_lentes.png', precio: 60),
    AccesorioItem(id: 'gorra_futbol_sinta', nombre: 'Gorra Fútbol Sinta', tipo: 'gorra', imagen: 'gorra_futbol_sinta.png', precio: 55),
    AccesorioItem(id: 'gorra_lentes_oscuros', nombre: 'Gorra con Lentes Oscuros', tipo: 'gorra', imagen: 'gorra_lentes_oscuros.png', precio: 65),
    AccesorioItem(id: 'gorra_lombriz', nombre: 'Gorra Lombriz 🪱', tipo: 'gorra', imagen: 'gorra_lombriz.png', precio: 80),
    AccesorioItem(id: 'gorra_parches_amarilla', nombre: 'Gorra Parches Amarilla', tipo: 'gorra', imagen: 'gorra_parches_amarilla.png', precio: 55),
    AccesorioItem(id: 'gorra_parches_azul', nombre: 'Gorra Parches Azul', tipo: 'gorra', imagen: 'gorra_parches_azul.png', precio: 55),
    AccesorioItem(id: 'gorra_parches_futbol', nombre: 'Gorra Parches Fútbol', tipo: 'gorra', imagen: 'gorra_parches_futbol.png', precio: 60),
    AccesorioItem(id: 'gorra_parches_gris', nombre: 'Gorra Parches Gris', tipo: 'gorra', imagen: 'gorra_parches_gris.png', precio: 50),
    AccesorioItem(id: 'gorra_parches_militar', nombre: 'Gorra Parches Militar', tipo: 'gorra', imagen: 'gorra_parches_militar.png', precio: 70),
    AccesorioItem(id: 'lentes_azules', nombre: 'Lentes Azules', tipo: 'lentes', imagen: 'lentes_azules.png', precio: 40),
    AccesorioItem(id: 'lentes_descanso', nombre: 'Lentes de Descanso', tipo: 'lentes', imagen: 'lentes_descanso.png', precio: 35),
    AccesorioItem(id: 'lentes_futbol', nombre: 'Lentes Fútbol', tipo: 'lentes', imagen: 'lentes_futbol.png', precio: 45),
    AccesorioItem(id: 'lentes_inventor', nombre: 'Lentes de Inventor', tipo: 'lentes', imagen: 'lentes_inventor.png', precio: 55),
    AccesorioItem(id: 'lentes_militares', nombre: 'Lentes Militares', tipo: 'lentes', imagen: 'lentes_militares.png', precio: 50),
    AccesorioItem(id: 'lentes_naranjas', nombre: 'Lentes Naranjas', tipo: 'lentes', imagen: 'lentes_naranjas.png', precio: 40),
    AccesorioItem(id: 'lentes_oscuros', nombre: 'Lentes Oscuros', tipo: 'lentes', imagen: 'lentes_oscuros.png', precio: 45),
    AccesorioItem(id: 'lentes_simples', nombre: 'Lentes Simples', tipo: 'lentes', imagen: 'lentes_simples.png', precio: 30),
    AccesorioItem(id: 'lentes_sol', nombre: 'Lentes de Sol', tipo: 'lentes', imagen: 'lentes_sol.png', precio: 50),
    AccesorioItem(id: 'collar_perlas', nombre: 'Collar de Perlas', tipo: 'collar', imagen: 'collar_perlas.png', precio: 70),
    AccesorioItem(id: 'collar_perlas_amarillas', nombre: 'Collar Perlas Amarillas', tipo: 'collar', imagen: 'collar_perlas_amarillas.png', precio: 75),
    AccesorioItem(id: 'collar_plateado_pluma', nombre: 'Collar Plateado con Pluma', tipo: 'collar', imagen: 'collar_plateado_pluma.png', precio: 80),
    AccesorioItem(id: 'collar_pluma', nombre: 'Collar de Pluma', tipo: 'collar', imagen: 'collar_pluma.png', precio: 65),
    AccesorioItem(id: 'sombrero_amarillo', nombre: 'Sombrero Amarillo', tipo: 'sombrero', imagen: 'sombrero_amarillo.png', precio: 60),
    AccesorioItem(id: 'sombrero_arcoiris', nombre: 'Sombrero Arcoíris', tipo: 'sombrero', imagen: 'sombrero_arcoiris.png', precio: 90),
    AccesorioItem(id: 'sombrero_azul', nombre: 'Sombrero Azul', tipo: 'sombrero', imagen: 'sombrero_azul.png', precio: 60),
    AccesorioItem(id: 'sombrero_estilo_flores', nombre: 'Sombrero con Flores', tipo: 'sombrero', imagen: 'sombrero_estilo_flores.png', precio: 75),
    AccesorioItem(id: 'sombrero_estilo_morado', nombre: 'Sombrero Morado', tipo: 'sombrero', imagen: 'sombrero_estilo_morado.png', precio: 65),
    AccesorioItem(id: 'sombrero_estilo_naranja', nombre: 'Sombrero Naranja', tipo: 'sombrero', imagen: 'sombrero_estilo_naranja.png', precio: 65),
    AccesorioItem(id: 'sombrero_rojo', nombre: 'Sombrero Rojo', tipo: 'sombrero', imagen: 'sombrero_rojo.png', precio: 60),
    AccesorioItem(id: 'sombrero_verde', nombre: 'Sombrero Verde', tipo: 'sombrero', imagen: 'sombrero_verde.png', precio: 60),
  ];
  
  Set<String> _comprados = {};
  Map<String, String?> _equipados = {};
  
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }
  
  Future<void> _cargarDatos() async {
    await _monedasService.init();
    await _accesoriosService.init();
    
    setState(() {
      _monedas = _monedasService.obtenerMonedas();
      _comprados = _accesoriosService.obtenerComprados(_personajeActual);
      _equipados = _accesoriosService.obtenerEquipados(_personajeActual);
    });
  }
  
  Future<void> _comprarAccesorio(AccesorioItem item) async {
    if (_monedas >= item.precio && !_comprados.contains(item.id)) {
      final exito = await _accesoriosService.comprarAccesorio(
        _personajeActual,
        item.id,
        item.precio,
      );
      
      if (exito) {
        setState(() {
          _monedas -= item.precio;
          _comprados.add(item.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Compraste ${item.nombre}! 🎉'),
            backgroundColor: AppTheme.verde,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (_comprados.contains(item.id)) {
      _equiparAccesorio(item);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes suficientes monedas 😢'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _equiparAccesorio(AccesorioItem item) {
    setState(() {
      if (_equipados[item.tipo] == item.id) {
        _equipados[item.tipo] = null;
      } else {
        _equipados[item.tipo] = item.id;
      }
    });
    
    _accesoriosService.equiparAccesorio(
      _personajeActual,
      _equipados['gorra'],
      _equipados['lentes'],
      _equipados['collar'],
      _equipados['sombrero'],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _equipados[item.tipo] == item.id
              ? '${item.nombre} equipado ✨'
              : '${item.nombre} desequipado',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final gorras = _accesorios.where((a) => a.tipo == 'gorra').toList();
    final lentes = _accesorios.where((a) => a.tipo == 'lentes').toList();
    final collares = _accesorios.where((a) => a.tipo == 'collar').toList();
    final sombreros = _accesorios.where((a) => a.tipo == 'sombrero').toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda de Accesorios'),
        backgroundColor: AppTheme.verde,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_monedas',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.fondo,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.verde.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text('Tu lombriz', style: TextStyle(fontFamily: 'Fredoka', fontSize: 18)),
                const SizedBox(height: 8),
                PersonajeConAccesorios(
                  personaje: _personajeActual,
                  gorraEquipada: _equipados['gorra'],
                  lentesEquipados: _equipados['lentes'],
                  collarEquipado: _equipados['collar'],
                  sombreroEquipado: _equipados['sombrero'],
                  size: 120,
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppTheme.verde,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.emoji_events), text: 'Gorras'),
                      Tab(icon: Icon(Icons.visibility), text: 'Lentes'),
                      Tab(icon: Icon(Icons.weekend), text: 'Collares'),
                      Tab(icon: Icon(Icons.beach_access), text: 'Sombreros'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildLista(gorras),
                        _buildLista(lentes),
                        _buildLista(collares),
                        _buildLista(sombreros),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLista(List<AccesorioItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final comprado = _comprados.contains(item.id);
        final equipado = _equipados[item.tipo] == item.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/images/accesorios/${item.imagen}'),
            ),
            title: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!comprado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 14, color: Colors.white),
                        Text('${item.precio}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                if (comprado && equipado)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check_circle, color: AppTheme.verde, size: 20),
                  ),
                IconButton(
                  icon: Icon(comprado ? Icons.swap_horiz : Icons.shopping_cart, size: 20),
                  color: comprado ? AppTheme.azulCielo : AppTheme.verde,
                  onPressed: () => _comprarAccesorio(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AccesorioItem {
  final String id;
  final String nombre;
  final String tipo;
  final String imagen;
  final int precio;
  
  AccesorioItem({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.imagen,
    required this.precio,
  });
}