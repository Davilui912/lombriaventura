import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/tienda_service.dart';
import 'carrito.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  final TiendaService _tiendaService = TiendaService();
  final List<Map<String, dynamic>> _carrito = [];

  void _agregarAlCarrito(producto) {
    setState(() {
      // Verificar si ya está en el carrito
      final index = _carrito.indexWhere((item) => item['id'] == producto.id);
      if (index >= 0) {
        _carrito[index]['cantidad']++;
      } else {
        _carrito.add({
          'id': producto.id,
          'nombre': producto.nombre,
          'precio': producto.precio,
          'imagen': producto.imagen,
          'cantidad': 1,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.imagen} ¡Agregado al carrito!'),
        backgroundColor: AppTheme.verde,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productos = _tiendaService.obtenerProductos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Tienda'),
        actions: [
          // Botón del carrito
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  if (_carrito.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tu carrito está vacío 🛒')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarritoScreen(carrito: _carrito),
                      ),
                    );
                  }
                },
              ),
              if (_carrito.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_carrito.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner ecológico
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.verde, Color(0xFF5DA82E)],
              ),
            ),
            child: Column(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 8),
                const Text(
                  '¡Empieza tu aventura!',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Fredoka',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consigue tu kit y ayuda al planeta 🌍',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                return _buildProductoCard(productos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(producto) {
    final esKitPrincipal = producto.id == 'kit_basico';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: esKitPrincipal ? AppTheme.verde : Colors.grey[200]!,
          width: esKitPrincipal ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta "Recomendado"
          if (esKitPrincipal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppTheme.amarillo,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Text(
                '⭐ Recomendado para empezar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cafe,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji y nombre
                Row(
                  children: [
                    Text(producto.imagen, style: const TextStyle(fontSize: 45)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fredoka',
                          color: AppTheme.cafe,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  producto.descripcion,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // ¿Qué incluye?
                const Text(
                  '📦 Incluye:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                ...producto.incluye.map<Widget>((item) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.verde, size: 16),
                          const SizedBox(width: 6),
                          Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),

                // Precio y botón
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${producto.precio.toStringAsFixed(2)} MXN',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.verde,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _agregarAlCarrito(producto),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Agregar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.verde,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}