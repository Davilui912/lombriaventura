import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/monedas_service.dart';

class TiendaAccesoriosScreen extends StatefulWidget {
  const TiendaAccesoriosScreen({super.key});

  @override
  State<TiendaAccesoriosScreen> createState() => _TiendaAccesoriosScreenState();
}

class _TiendaAccesoriosScreenState extends State<TiendaAccesoriosScreen> {
  final MonedasService _monedasService = MonedasService();
  late List<Map<String, dynamic>> _accesorios;
  int _saldo = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _saldo = _monedasService.obtenerSaldo();
      _accesorios = _monedasService.obtenerAccesorios();
    });
  }

  void _comprar(Map<String, dynamic> accesorio) {
    if (_saldo < accesorio['precio']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Necesitas ${accesorio['precio']} monedas 💰'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${accesorio['emoji']} ${accesorio['nombre']}'),
        content: Text('¿Comprar por ${accesorio['precio']} monedas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final exito = await _monedasService.comprarAccesorio(
                accesorio['id'],
                accesorio['precio'] as int,
              );
              Navigator.pop(ctx);
              if (exito) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Comprado! 🎉'), backgroundColor: AppTheme.verde),
                );
                _cargarDatos();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde),
            child: const Text('Comprar ✅', style: TextStyle(color: Colors.white)),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text('$_saldo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.amarillo, AppTheme.amarillo.withValues(alpha: 0.6)]),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🪙', style: TextStyle(fontSize: 45)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tus monedas', style: TextStyle(fontSize: 16, color: AppTheme.cafe)),
                    Text('Compra accesorios para Lola y Lalo', style: TextStyle(fontSize: 12, color: AppTheme.cafe)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _accesorios.length,
              itemBuilder: (context, index) {
                final acc = _accesorios[index];
                return _buildAccesorioCard(acc);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesorioCard(Map<String, dynamic> acc) {
    final comprado = acc['comprado'] == true;
    final alcanza = _saldo >= (acc['precio'] as int);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: comprado ? AppTheme.verde : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: comprado ? AppTheme.verde.withValues(alpha: 0.15) : AppTheme.amarillo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(child: Text(acc['emoji'], style: const TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              acc['nombre'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.cafe),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Para ${acc['personaje']}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 10),
          comprado
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.verde.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('✅ Comprado', style: TextStyle(fontSize: 12, color: AppTheme.verde)),
                )
              : GestureDetector(
                  onTap: alcanza ? () => _comprar(acc) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: alcanza ? AppTheme.verde : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🪙 ${acc['precio']}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: alcanza ? Colors.white : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}