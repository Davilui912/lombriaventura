import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/diario_service.dart';
import 'nueva_entrada.dart';
import 'dart:io';

class MiCompostaScreen extends StatefulWidget {
  const MiCompostaScreen({super.key});

  @override
  State<MiCompostaScreen> createState() => _MiCompostaScreenState();
}

class _MiCompostaScreenState extends State<MiCompostaScreen> {
  final DiarioService _diarioService = DiarioService();
  List<dynamic> _entradas = [];
  bool _vistaGaleria = false;

  @override
  void initState() {
    super.initState();
    _cargarEntradas();
  }

  void _cargarEntradas() {
    setState(() {
      _entradas = _diarioService.obtenerEntradas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Mi Composta'),
        actions: [
          // Botón para cambiar vista (línea de tiempo / galería)
          IconButton(
            icon: Icon(_vistaGaleria ? Icons.view_timeline : Icons.grid_view),
            onPressed: () {
              setState(() => _vistaGaleria = !_vistaGaleria);
            },
          ),
        ],
      ),
      body: _entradas.isEmpty ? _buildEmptyState() : _buildContenido(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _irANuevaEntrada(),
        backgroundColor: AppTheme.verde,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Nueva entrada',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Fredoka',
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_camera, size: 100, color: AppTheme.verde),
            const SizedBox(height: 20),
            const Text(
              '¡Tu diario de composta!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 28,
                color: AppTheme.verde,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              'Toma fotos de tu composta cada semana para ver cómo crece y cambia. '
              '¡Será increíble ver tu progreso! 🌱',
              style: TextStyle(fontSize: 16, color: AppTheme.cafe),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _irANuevaEntrada(),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('¡Mi primera foto!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amarillo,
                foregroundColor: AppTheme.cafe,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_vistaGaleria) {
      return _buildGaleria();
    }
    return _buildLineaTiempo();
  }

  Widget _buildLineaTiempo() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entradas.length,
      itemBuilder: (context, index) {
        final entrada = _entradas[index];
        return _buildTarjetaEntrada(entrada);
      },
    );
  }

  Widget _buildTarjetaEntrada(dynamic entrada) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.cafe),
                    const SizedBox(width: 8),
                    Text(
                      _formatearFecha(entrada.fecha),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.cafe,
                      ),
                    ),
                  ],
                ),
                Text(
                  entrada.estado,
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fotos
            if (entrada.fotosRutas.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: entrada.fotosRutas.length,
                  itemBuilder: (context, fotoIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(entrada.fotosRutas[fotoIndex]),
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),

            // Nota
            if (entrada.nota != null && entrada.nota.toString().isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 18, color: AppTheme.verde),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entrada.nota,
                        style: const TextStyle(fontSize: 14, color: AppTheme.cafe),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón compartir
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: AppTheme.verde),
                  onPressed: () => _compartirEntrada(entrada),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmarEliminar(entrada.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaleria() {
    // Recolectar todas las fotos
    List<Map<String, dynamic>> todasLasFotos = [];
    for (var entrada in _entradas) {
      for (var foto in entrada.fotosRutas) {
        todasLasFotos.add({
          'ruta': foto,
          'fecha': entrada.fecha,
          'entradaId': entrada.id,
        });
      }
    }

    if (todasLasFotos.isEmpty) {
      return Center(
        child: Text(
          '¡Aún no hay fotos! Toca el botón + para empezar.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: todasLasFotos.length,
      itemBuilder: (context, index) {
        final foto = todasLasFotos[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(foto['ruta']),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void _irANuevaEntrada() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NuevaEntradaScreen()),
    );
    if (resultado == true) {
      _cargarEntradas();
    }
  }

  void _compartirEntrada(entrada) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Compartiendo tu progreso! 🌱'),
        backgroundColor: AppTheme.verde,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar entrada?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _diarioService.eliminarEntrada(id);
              _cargarEntradas();
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]}, ${fecha.year}';
  }
}