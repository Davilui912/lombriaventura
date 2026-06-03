import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/conversacion_service.dart';
import '../models/conversacion.dart';
import 'chat_ia_screen.dart';

class HistorialChatScreen extends StatefulWidget {
  const HistorialChatScreen({super.key});

  @override
  State<HistorialChatScreen> createState() => _HistorialChatScreenState();
}

class _HistorialChatScreenState extends State<HistorialChatScreen> {
  final ConversacionService _convService = ConversacionService();
  List<Conversacion> _conversaciones = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _cargarConversaciones();
  }
  
  Future<void> _cargarConversaciones() async {
    setState(() => _isLoading = true);
    final conversaciones = await _convService.obtenerTodas();
    setState(() {
      _conversaciones = conversaciones;
      _isLoading = false;
    });
  }
  
  Future<void> _eliminarConversacion(String id) async {
    await _convService.eliminarConversacion(id);
    _cargarConversaciones();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de chats'),
        backgroundColor: AppTheme.verde,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay conversaciones guardadas',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ir al chat'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _conversaciones.length,
                  itemBuilder: (context, index) {
                    final conv = _conversaciones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.verde.withValues(alpha: 0.2),
                          child: const Icon(Icons.chat, color: AppTheme.verde),
                        ),
                        title: Text(
                          conv.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatFecha(conv.fecha),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _eliminarConversacion(conv.id),
                        ),
                        onTap: () {
                          Navigator.pop(context, conv.id);
                        },
                      ),
                    );
                  },
                ),
    );
  }
  
  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);
    
    if (diff.inDays == 0) {
      return 'Hoy, ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}