import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';

class CapacitacionScreen extends StatefulWidget {
  const CapacitacionScreen({super.key});

  @override
  State<CapacitacionScreen> createState() => _CapacitacionScreenState();
}

class _CapacitacionScreenState extends State<CapacitacionScreen> {
  final MonedasService _monedasService = MonedasService();
  
  // Controladores para el formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _paisController = TextEditingController();
  final TextEditingController _invitadoPorController = TextEditingController();
  
  List<Map<String, dynamic>> _capacitados = [];
  int _totalGanado = 0;
  int _monedas = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _monedasService.init();
    await _cargarCapacitados();
    
    setState(() {
      _monedas = _monedasService.obtenerMonedas();
      _calcularTotalGanado();
    });
  }

  Future<void> _cargarCapacitados() async {
    final box = await Hive.openBox('capacitaciones');
    final lista = box.get('capacitados', defaultValue: <Map<String, dynamic>>[]);
    setState(() {
      _capacitados = List<Map<String, dynamic>>.from(lista);
    });
  }

  void _calcularTotalGanado() {
    _totalGanado = _capacitados.length * 50; // 50 monedas por cada capacitado
  }

  Future<void> _guardarCapacitado() async {
    // Validar campos
    if (_nombreController.text.trim().isEmpty) {
      _mostrarError('Ingresa el nombre completo');
      return;
    }
    if (_edadController.text.trim().isEmpty) {
      _mostrarError('Ingresa la edad');
      return;
    }
    if (_municipioController.text.trim().isEmpty) {
      _mostrarError('Ingresa el municipio');
      return;
    }
    if (_estadoController.text.trim().isEmpty) {
      _mostrarError('Ingresa el estado');
      return;
    }
    if (_paisController.text.trim().isEmpty) {
      _mostrarError('Ingresa el país');
      return;
    }

    final nuevoCapacitado = {
      'nombre': _nombreController.text.trim(),
      'edad': _edadController.text.trim(),
      'municipio': _municipioController.text.trim(),
      'estado': _estadoController.text.trim(),
      'pais': _paisController.text.trim(),
      'invitadoPor': _invitadoPorController.text.trim().isEmpty ? 'Nadie' : _invitadoPorController.text.trim(),
      'fecha': DateTime.now().toIso8601String(),
    };

    // Guardar en Hive
    final box = await Hive.openBox('capacitaciones');
    final lista = List<Map<String, dynamic>>.from(box.get('capacitados', defaultValue: []));
    lista.add(nuevoCapacitado);
    await box.put('capacitados', lista);

    // Dar monedas
    await _monedasService.agregarMonedas(50);
    
    // Limpiar formulario
    _nombreController.clear();
    _edadController.clear();
    _municipioController.clear();
    _estadoController.clear();
    _paisController.clear();
    _invitadoPorController.clear();

    // Recargar datos
    await _cargarCapacitados();
    setState(() {
      _monedas = _monedasService.obtenerMonedas();
      _calcularTotalGanado();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Capacitación registrada! Ganaste 50 monedas 🪙'),
        backgroundColor: AppTheme.verde,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Capacitación'),
        backgroundColor: Colors.orange,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$_monedas', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.person_add), text: 'Registrar'),
                Tab(icon: Icon(Icons.history), text: 'Historial'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Pestaña Registrar
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.school, size: 40, color: Colors.orange),
                              SizedBox(height: 8),
                              Text(
                                'Registra a un nuevo niño capacitado',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Comparte tus conocimientos y gana 50 monedas por cada niño que capacites.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('📝 Datos del capacitado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildCampo('Nombre completo', _nombreController, Icons.person),
                        const SizedBox(height: 12),
                        _buildCampo('Edad', _edadController, Icons.cake, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildCampo('Municipio', _municipioController, Icons.location_city),
                        const SizedBox(height: 12),
                        _buildCampo('Estado', _estadoController, Icons.map),
                        const SizedBox(height: 12),
                        _buildCampo('País', _paisController, Icons.public),
                        const SizedBox(height: 12),
                        _buildCampo('¿Quién te invitó? (Opcional)', _invitadoPorController, Icons.people),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _guardarCapacitado,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text(
                              'Registrar capacitación',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pestaña Historial
                  _capacitados.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay capacitaciones registradas aún',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _capacitados.length,
                          itemBuilder: (context, index) {
                            final item = _capacitados[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.withValues(alpha: 0.2),
                                  child: const Icon(Icons.person, color: Colors.orange),
                                ),
                                title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${item['edad']} años • ${item['municipio']}, ${item['estado']}\nInvitado por: ${item['invitadoPor']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                                    Text('+50', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}