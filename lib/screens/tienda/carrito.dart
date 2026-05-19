import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CarritoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;

  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  double get _total {
    double total = 0;
    for (var item in widget.carrito) {
      total += (item['precio'] as double) * (item['cantidad'] as int);
    }
    return total;
  }

  void _comprar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🛒 ¿Confirmar compra?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Tus papás te ayudan a completar la compra?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '👨‍👩‍👧 Pide ayuda a un adulto para ingresar los datos de envío y pago.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 ¡Pedido realizado! Pronto recibirás tu kit.'),
                  backgroundColor: AppTheme.verde,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde),
            child: const Text('Confirmar ✅', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Mi Carrito'),
      ),
      body: widget.carrito.isEmpty
          ? const Center(
              child: Text('Tu carrito está vacío 🛒', style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.carrito.length,
                    itemBuilder: (context, index) {
                      final item = widget.carrito[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: Text(item['imagen'], style: const TextStyle(fontSize: 35)),
                          title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${(item['precio'] as double).toStringAsFixed(2)} MXN'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (item['cantidad'] > 1) {
                                      item['cantidad']--;
                                    } else {
                                      widget.carrito.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('${item['cantidad']}', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    item['cantidad']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Total y botón comprar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontFamily: 'Fredoka')),
                          Text(
                            '\$${_total.toStringAsFixed(2)} MXN',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.verde,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _comprar,
                          icon: const Icon(Icons.lock),
                          label: const Text('Comprar ahora', style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.verde,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}