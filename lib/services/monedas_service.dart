import 'package:hive_flutter/hive_flutter.dart';

class MonedasService {
  late Box _box;
  late Box _historialBox;
  
  Future<void> init() async {
    _box = await Hive.openBox('monedas');
    _historialBox = await Hive.openBox('historial_monedas');
  }
  
  // Obtener monedas actuales
  int obtenerMonedas() {
    return _box.get('total', defaultValue: 0);
  }
  
  // Obtener saldo (alias de obtenerMonedas)
  int obtenerSaldo() {
    return obtenerMonedas();
  }
  
  // Agregar monedas (genérico)
  Future<void> agregarMonedas(int cantidad) async {
    final actual = obtenerMonedas();
    await _box.put('total', actual + cantidad);
  }
  
  // Ganar monedas por actividad (juego, diario, etc.)
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
    await _box.put('total', actual + cantidad);
    
    // Guardar en historial
    await _guardarEnHistorial(cantidad, descripcion);
  }
  
  // Gastar monedas
  Future<bool> gastarMonedas(int cantidad) async {
    final actual = obtenerMonedas();
    if (actual >= cantidad) {
      await _box.put('total', actual - cantidad);
      await _guardarEnHistorial(-cantidad, '🛍️ Compra en tienda');
      return true;
    }
    return false;
  }
  
  // Guardar transacción en historial
  Future<void> _guardarEnHistorial(int cantidad, String descripcion) async {
    final historial = obtenerHistorial();
    final nuevaTransaccion = {
      'fecha': DateTime.now().toIso8601String(),
      'cantidad': cantidad,
      'descripcion': descripcion,
    };
    historial.insert(0, nuevaTransaccion); // Más reciente primero
    await _historialBox.put('transacciones', historial);
  }
  
  // Obtener historial de transacciones
  List<Map<String, dynamic>> obtenerHistorial() {
    final historial = _historialBox.get('transacciones', defaultValue: <Map<String, dynamic>>[]);
    return List<Map<String, dynamic>>.from(historial);
  }
}