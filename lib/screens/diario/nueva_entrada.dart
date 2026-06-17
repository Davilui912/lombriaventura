import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/monedas_service.dart';
import '../../services/diario_service.dart';

class NuevaEntradaScreen extends StatefulWidget {
  const NuevaEntradaScreen({super.key});

  @override
  State<NuevaEntradaScreen> createState() => _NuevaEntradaScreenState();
}

class _NuevaEntradaScreenState extends State<NuevaEntradaScreen> {
  final DiarioService _diarioService = DiarioService();
  final TextEditingController _notaController = TextEditingController();
  
  // ✅ Temperatura con opciones
  String? _temperaturaSeleccionada;
  final List<String> _opcionesTemperatura = ['❄️ Frío', '🌤️ Buen clima', '☀️ Caliente'];
  
  final TextEditingController _compostaController = TextEditingController();
  final TextEditingController _lixiviadoController = TextEditingController();
  
  List<String> _fotosTomadas = [];
  String _estadoSeleccionado = '😊';
  int _humedad = 5;
  String _tipoResiduo = 'Mixto';
  bool _guardando = false;
  bool _mostrarAvanzado = false;

  final List<Map<String, String>> _estados = [
    {'emoji': '😊', 'label': '¡Excelente!'},
    {'emoji': '😐', 'label': 'Regular'},
    {'emoji': '😟', 'label': 'Necesita ayuda'},
  ];

  final List<String> _tiposResiduo = ['Frutas', 'Verduras', 'Cáscaras', 'Café', 'Mixto'];

  @override
  void dispose() {
    _notaController.dispose();
    _compostaController.dispose();
    _lixiviadoController.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    if (_fotosTomadas.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 3 fotos por entrada 📸')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tomar foto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.verde),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final ruta = await _diarioService.tomarFoto();
                  if (ruta != null) setState(() => _fotosTomadas.add(ruta));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.azulCielo),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final ruta = await _diarioService.seleccionarDeGaleria();
                  if (ruta != null) setState(() => _fotosTomadas.add(ruta));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarEntrada() async {
    setState(() => _guardando = true);

    await _diarioService.guardarEntrada(
      fotosRutas: _fotosTomadas,
      nota: _notaController.text.isNotEmpty ? _notaController.text : null,
      estado: _estadoSeleccionado,
      humedad: _humedad,
      temperaturaTexto: _temperaturaSeleccionada,
      tipoResiduo: _tipoResiduo,
      produccionComposta: _compostaController.text.isNotEmpty ? double.tryParse(_compostaController.text) : null,
      produccionLixiviado: _lixiviadoController.text.isNotEmpty ? double.tryParse(_lixiviadoController.text) : null,
    );
    await MonedasService().ganarPorActividad('diario');
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Nueva entrada'),
        backgroundColor: AppTheme.verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotos
            const Text('📸 Fotos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _tomarFoto,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9EE),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTheme.verde, width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: AppTheme.verde, size: 35),
                        SizedBox(height: 4),
                        Text('Agregar', style: TextStyle(fontSize: 11, color: AppTheme.verde)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fotosTomadas.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(File(_fotosTomadas[index]), width: 100, height: 100, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2, right: 2,
                              child: GestureDetector(
                                onTap: () => setState(() => _fotosTomadas.removeAt(index)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Estado
            const Text('🌱 ¿Cómo va?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _estados.map((estado) {
                final sel = _estadoSeleccionado == estado['emoji'];
                return GestureDetector(
                  onTap: () => setState(() => _estadoSeleccionado = estado['emoji']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.verde.withValues(alpha: 0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppTheme.verde : Colors.grey[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(estado['emoji']!, style: const TextStyle(fontSize: 30)),
                        Text(estado['label']!, style: TextStyle(fontSize: 11, color: sel ? AppTheme.verde : Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Nota
            const Text('📝 Nota', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
            const SizedBox(height: 10),
            TextField(
              controller: _notaController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ej: Hoy les di cáscaras de plátano...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true, fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 15),

            // Botón avanzado
            GestureDetector(
              onTap: () => setState(() => _mostrarAvanzado = !_mostrarAvanzado),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.verde.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.verde.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_mostrarAvanzado ? Icons.expand_less : Icons.expand_more, color: AppTheme.verde),
                    const SizedBox(width: 6),
                    Text(
                      _mostrarAvanzado ? 'Ocultar detalles' : 'Agregar más detalles 🌱',
                      style: const TextStyle(color: AppTheme.verde, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Campos avanzados
            if (_mostrarAvanzado) ...[
              const SizedBox(height: 15),

              // Humedad
              const Text('💧 Humedad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Seco', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Expanded(
                    child: Slider(
                      value: _humedad.toDouble(),
                      min: 1, max: 10, divisions: 9,
                      activeColor: AppTheme.verde,
                      label: '$_humedad/10',
                      onChanged: (val) => setState(() => _humedad = val.round()),
                    ),
                  ),
                  const Text('Empapado', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Center(
                child: Text(
                  _humedad <= 3 ? '🟡 Muy seco' : _humedad <= 6 ? '🟢 Ideal' : _humedad <= 8 ? '🟡 Húmedo' : '🔴 Muy mojado',
                  style: const TextStyle(fontSize: 13),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Temperatura (Frío / Buen clima / Caliente)
              const Text('🌡️ Temperatura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _opcionesTemperatura.map((opcion) {
                  return ChoiceChip(
                    label: Text(opcion),
                    selected: _temperaturaSeleccionada == opcion,
                    onSelected: (selected) {
                      setState(() {
                        _temperaturaSeleccionada = selected ? opcion : null;
                      });
                    },
                    selectedColor: AppTheme.verde,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: _temperaturaSeleccionada == opcion ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Tipo de residuo
              const Text('🍎 Tipo de residuo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _tiposResiduo.map((tipo) {
                  final sel = _tipoResiduo == tipo;
                  return ChoiceChip(
                    label: Text(tipo),
                    selected: sel,
                    selectedColor: AppTheme.verde.withValues(alpha: 0.3),
                    onSelected: (_) => setState(() => _tipoResiduo = tipo),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Producción (puños y cucharadas)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🪱 Composta (puños)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _compostaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ej: 2 puños',
                            suffixText: 'puños',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💧 Lixiviado (cucharadas)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.cafe)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _lixiviadoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ej: 3 cucharadas',
                            suffixText: 'cucharadas',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarEntrada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _guardando
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('💾 Guardar entrada', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}