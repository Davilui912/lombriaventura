import 'package:hive_flutter/hive_flutter.dart';

class MonedasService {
  late Box _monedasBox;      // Para monedas
  late Box _historialBox;    // Para historial de ventas
  
  Future<void> init() async {
    _monedasBox = await Hive.openBox('monedas');
    _historialBox = await Hive.openBox('historial_ventas');  // ✅ Box separado
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
    
    // Guardar en historial (monedas ganadas)
    await _guardarEnHistorial(cantidad, descripcion);
  }
  
  Future<bool> gastarMonedas(int cantidad) async {
    final actual = obtenerMonedas();
    if (actual >= cantidad) {
      await _monedasBox.put('total', actual - cantidad);
      await _guardarEnHistorial(-cantidad, '🛍️ Compra en tienda');
      return true;
    }
    return false;
  }
  
  // ========== HISTORIAL DE VENTAS ==========
  
  // ✅ Agregar venta al historial (se mantiene al cerrar sesión)
  Future<void> agregarVenta({
    required int cantidad,
    required String descripcion,
  }) async {
    final historial = _historialBox.get('lista', defaultValue: <Map<String, dynamic>>[]);
    historial.add({
      'fecha': DateTime.now().toIso8601String(),
      'cantidad': cantidad,
      'descripcion': descripcion,
    });
    await _historialBox.put('lista', historial);
  }
  
  // ✅ Obtener historial de ventas
  List<Map<String, dynamic>> obtenerHistorialVentas() {
    final historial = _historialBox.get('lista', defaultValue: <Map<String, dynamic>>[]);
    return List<Map<String, dynamic>>.from(historial);
  }
  
  // ========== HISTORIAL DE MONEDAS (ganadas/gastadas) ==========
  
  Future<void> _guardarEnHistorial(int cantidad, String descripcion) async {
    final historial = obtenerHistorialMonedas();
    final nuevaTransaccion = {
      'fecha': DateTime.now().toIso8601String(),
      'cantidad': cantidad,
      'descripcion': descripcion,
    };
    historial.insert(0, nuevaTransaccion);
    await _monedasBox.put('historial_monedas', historial);
  }
  
  List<Map<String, dynamic>> obtenerHistorialMonedas() {
    final historial = _monedasBox.get('historial_monedas', defaultValue: <Map<String, dynamic>>[]);
    return List<Map<String, dynamic>>.from(historial);
  }
  
  // ========== MANTENER COMPATIBILIDAD (para código existente) ==========
  
  // ⚠️ Deprecado: usar obtenerHistorialVentas() para ventas
  // y obtenerHistorialMonedas() para monedas
  List<Map<String, dynamic>> obtenerHistorial() {
    // Para mantener compatibilidad, devolvemos el historial de monedas
    return obtenerHistorialMonedas();
  }
  
  Future<void> agregarTransaccion({
    required int cantidad,
    required String descripcion,
  }) async {
    // Para mantener compatibilidad, guardamos en monedas
    await _guardarEnHistorial(cantidad, descripcion);
  }
}