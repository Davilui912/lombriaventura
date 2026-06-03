import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversacion.dart';

class ConversacionService {
  // ✅ Usar lateinit pero asegurando que se inicialice antes de usar
  late final Box<Conversacion> _box;
  
  // ✅ Constructor que inicializa inmediatamente
  ConversacionService() {
    _init();
  }
  
  Future<void> _init() async {
    _box = await Hive.openBox<Conversacion>('conversaciones');
  }
  
  // ✅ Asegurar que el box esté listo antes de usarlo
  Future<Box<Conversacion>> get box async {
    await _init();
    return _box;
  }
  
  // ✅ Métodos que esperan a que el box esté listo
  Future<List<Conversacion>> obtenerTodas() async {
    final box = await this.box;
    final conversaciones = box.values.toList();
    conversaciones.sort((a, b) => b.fecha.compareTo(a.fecha));
    return conversaciones;
  }
  
  Future<void> guardarConversacion(Conversacion conversacion) async {
    final box = await this.box;
    await box.put(conversacion.id, conversacion);
  }
  
  Future<void> eliminarConversacion(String id) async {
    final box = await this.box;
    await box.delete(id);
  }
  
  Future<Conversacion?> obtenerPorId(String id) async {
    final box = await this.box;
    return box.get(id);
  }
  
  String generarTitulo(String primeraPregunta) {
    final titulo = primeraPregunta.length > 30 
        ? '${primeraPregunta.substring(0, 30)}...' 
        : primeraPregunta;
    return titulo;
  }
}