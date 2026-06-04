import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversacion.dart';

class ConversacionService {
  static ConversacionService? _instance;
  late Box<Conversacion> _box;
  bool _isInitialized = false;
  
  // ✅ Constructor privado (agregar esto)
  ConversacionService._internal();
  
  // ✅ Método para obtener la instancia única
  static Future<ConversacionService> getInstance() async {
    if (_instance == null) {
      _instance = ConversacionService._internal();  // Usar constructor privado
      await _instance!._init();
    }
    return _instance!;
  }
  
  // Inicialización asíncrona
  Future<void> _init() async {
    _box = await Hive.openBox<Conversacion>('conversaciones');
    _isInitialized = true;
    print('✅ ConversacionService inicializado correctamente');
  }
  
  // Asegurar que el box esté listo
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }
  
  // Obtener todas las conversaciones
  Future<List<Conversacion>> obtenerTodas() async {
    await _ensureInitialized();
    final conversaciones = _box.values.toList();
    conversaciones.sort((a, b) => b.fecha.compareTo(a.fecha));
    return conversaciones;
  }
  
  // Guardar conversación
  Future<void> guardarConversacion(Conversacion conversacion) async {
    await _ensureInitialized();
    print('Guardando conversación: ${conversacion.id}');
    print('Mensajes: ${conversacion.mensajes.length}');
    await _box.put(conversacion.id, conversacion);
    print('✅ Guardado exitoso');
  }
  
  // Eliminar conversación
  Future<void> eliminarConversacion(String id) async {
    await _ensureInitialized();
    await _box.delete(id);
  }
  
  // Obtener por ID
  Future<Conversacion?> obtenerPorId(String id) async {
    await _ensureInitialized();
    return _box.get(id);
  }
  
  // Generar título automático
  String generarTitulo(String primeraPregunta) {
    final titulo = primeraPregunta.length > 30 
        ? '${primeraPregunta.substring(0, 30)}...' 
        : primeraPregunta;
    return titulo;
  }
}