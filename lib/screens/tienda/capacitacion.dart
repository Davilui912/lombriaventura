import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';

class CapacitacionScreen extends StatefulWidget {
  const CapacitacionScreen({super.key});

  @override
  State<CapacitacionScreen> createState() => _CapacitacionScreenState();
}

class _CapacitacionScreenState extends State<CapacitacionScreen> {
  final MonedasService _monedasService = MonedasService();
  int _monedas = 0;
  int _ninosCapacitados = 0;
  final TextEditingController _ninoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _monedasService.init();
    setState(() {
      _monedas = _monedasService.obtenerMonedas();
    });
  }

  Future<void> _capacitarNino() async {
    final nombre = _ninoController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del niño/a')),
      );
      return;
    }

    setState(() {
      _ninosCapacitados++;
      _monedas += 50; // Gana 50 monedas por capacitar
      _ninoController.clear();
    });

    await _monedasService.agregarMonedas(50);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Capacitaste a $nombre! Ganaste 50 monedas 🪙'),
        backgroundColor: AppTheme.verde,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Capacitación'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    '🌟 Capacita a otros niños',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Comparte tus conocimientos sobre lombricomposta y gana monedas por cada niño que capacites.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '📊 Tu progreso',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Niños capacitados', style: TextStyle(color: Colors.grey)),
                            Text('$_ninosCapacitados', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Monedas ganadas', style: TextStyle(color: Colors.grey)),
                            Text('${_ninosCapacitados * 50}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Registra un nuevo niño capacitado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ninoController,
              decoration: InputDecoration(
                hintText: 'Nombre del niño/a',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.person_add),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _capacitarNino,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Registrar capacitación',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}