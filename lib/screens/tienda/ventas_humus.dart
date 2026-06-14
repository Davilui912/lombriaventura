import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';

class VentasHumusScreen extends StatefulWidget {
  const VentasHumusScreen({super.key});

  @override
  State<VentasHumusScreen> createState() => _VentasHumusScreenState();
}

class _VentasHumusScreenState extends State<VentasHumusScreen> {
  final MonedasService _monedasService = MonedasService();
  int _cantidad = 1;
  int _monedas = 0;

  @override
  void initState() {
    super.initState();
    _cargarMonedas();
  }

  Future<void> _cargarMonedas() async {
    await _monedasService.init();
    setState(() {
      _monedas = _monedasService.obtenerMonedas();
    });
  }

  Future<void> _vender() async {
    final precioTotal = _cantidad * 10; // $10 por kilo de humus
    await _monedasService.agregarMonedas(precioTotal);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Vendiste ${_cantidad}kg de humus! Ganaste $precioTotal monedas 🪙'),
          backgroundColor: AppTheme.verde,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vender humus'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.agriculture, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Precio: \$10 por kilo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text('Cantidad a vender (kg):', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 40),
                  onPressed: () => setState(() {
                    if (_cantidad > 1) _cantidad--;
                  }),
                ),
                Container(
                  width: 80,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_cantidad',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 40),
                  onPressed: () => setState(() => _cantidad++),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Total: \$${_cantidad * 10} MXN',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _vender,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Registrar venta',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}