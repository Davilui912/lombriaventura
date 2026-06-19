import 'package:hive_flutter/hive_flutter.dart';

class MonedasService {
  // 1. Convertimos la clase en un Singleton para que sea única en toda la app
  static final MonedasService _instancia = MonedasService._interno();
  factory MonedasService() => _instancia;
  MonedasService._interno();

  late Box _monedasBox;
  late Box _historialBox;
  bool _isInitialized = false; // Evita re-inicializar el box si ya está abierto
  
  Future<void> init() async {
    if (_isInitialized) return;
    _monedasBox = await Hive.openBox('monedas');
    _historialBox = await Hive.openBox('historial_ventas');
    _isInitialized = true;
  }
  
  // ========== MONEDAS ==========
  
  int obtenerMonedas() {
    return _monedasBox.get('total', defaultValue: 0);
  }
  
  int obtenerSaldo() {
    return obtenerMonedas();
  }
  
  Future<void> agregarMonedas(int cantidad) async {
    final actual = obtenerMonedas();
    await _monedasBox.put('total', actual + cantidad);
  }
  
  Future<void> ganarPorActividad(String actividad) async {
    int cantidad = 0;
    String descripcion = '';
    
    switch (actividad) {
      case 'juego':
        cantidad = 10;
        descripcion = '🎮 Ganaste un juego';
        break;
      case 'diario':
        cantidad = 5;
        descripcion = '📝 Registraste en tu diario';
        break;
      case 'cuestionario':
        cantidad = 15;
        descripcion = '📚 Completaste un cuestionario';
        break;
      case 'reto':
        cantidad = 20;
        descripcion = '🎯 Completaste un reto';
        break;
      default:
        cantidad = 1;
        descripcion = '✨ Actividad completada';
    }
    
    final actual = obtenerMonedas();
    await _monedasBox.put('total', actual + cantidad);
  }
  
  Future<bool> gastarMonedas(int cantidad) async {
    final actual = obtenerMonedas();
    if (actual >= cantidad) {
      await _monedasBox.put('total', actual - cantidad);
      return true;
    }
    return false;
  }
  
  // ========== HISTORIAL DE VENTAS (Persistencia Corregida) ==========
  
  Future<void> agregarVenta({
    required int cantidad,
    required String descripcion,
  }) async {
    // 💥 CORRECCIÓN AQUÍ: Obtenemos como List dinámico primero
    final datosRaw = _historialBox.get('lista', defaultValue: []);
    
    // Lo convertimos explícitamente a una lista de mapas limpia que Hive sí pueda guardar
    final List<Map<String, dynamic>> historial = List<dynamic>.from(datosRaw)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    historial.add({
      'fecha': DateTime.now().toIso8601String(),
      'cantidad': cantidad,
      'descripcion': descripcion,
    });

    // Guardamos la nueva lista estructurada
    await _historialBox.put('lista', historial);
    print('✅ Venta guardada y persistida en disco: $descripcion - $cantidad');
  }
  
  List<Map<String, dynamic>> obtenerHistorialVentas() {
    final datosRaw = _historialBox.get('lista', defaultValue: []);
    
    // 💥 CORRECCIÓN AQUÍ: Aseguramos el casteo al leer para evitar errores de tipo en la UI
    return List<dynamic>.from(datosRaw)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
  
  Future<void> limpiarHistorialVentas() async {
    await _historialBox.put('lista', <Map<String, dynamic>>[]);
  }
}