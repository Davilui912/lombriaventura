import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/diario_service.dart';

class NuevaEntradaScreen extends StatefulWidget {
  const NuevaEntradaScreen({super.key});

  @override
  State<NuevaEntradaScreen> createState() => _NuevaEntradaScreenState();
}

class _NuevaEntradaScreenState extends State<NuevaEntradaScreen> {
  final DiarioService _diarioService = DiarioService();
  final TextEditingController _notaController = TextEditingController();
  List<String> _fotosTomadas = [];
  String _estadoSeleccionado = '😊';
  bool _guardando = false;

  final List<Map<String, String>> _estados = [
    {'emoji': '😊', 'label': '¡Excelente!'},
    {'emoji': '😐', 'label': 'Regular'},
    {'emoji': '😟', 'label': 'Necesita ayuda'},
  ];

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
              const Text(
                'Tomar foto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.verde),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final ruta = await _diarioService.tomarFoto();
                  if (ruta != null) {
                    setState(() => _fotosTomadas.add(ruta));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.azulCielo),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final ruta = await _diarioService.seleccionarDeGaleria();
                  if (ruta != null) {
                    setState(() => _fotosTomadas.add(ruta));
                  }
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
    );

    if (mounted) {
      Navigator.pop(context, true); // true = se guardó algo
    }
  }

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Nueva entrada'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de fotos
            const Text(
              '📸 Fotos de tu composta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Botón para tomar foto
                GestureDetector(
                  onTap: _tomarFoto,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9EE),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTheme.verde, width: 2, strokeAlign: BorderSide.strokeAlignInside),
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
                // Fotos tomadas
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fotosTomadas.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(_fotosTomadas[index]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _fotosTomadas.removeAt(index));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Estado de la composta
            const Text(
              '🌱 ¿Cómo va tu composta?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _estados.map((estado) {
                final seleccionado = _estadoSeleccionado == estado['emoji'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _estadoSeleccionado = estado['emoji']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: seleccionado ? AppTheme.verde.withValues(alpha: 0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: seleccionado ? AppTheme.verde : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(estado['emoji']!, style: const TextStyle(fontSize: 35)),
                        const SizedBox(height: 4),
                        Text(
                          estado['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: seleccionado ? AppTheme.verde : Colors.grey[600],
                            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Nota
            const Text(
              '📝 Nota (opcional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.cafe),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notaController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ej: Hoy les di cáscaras de plátano...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 40),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarEntrada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verde,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('💾 Guardar entrada', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}