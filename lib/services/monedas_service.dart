import 'package:hive_flutter/hive_flutter.dart';

class MonedasService {
  static const String _boxName = 'monedas';

  // Obtener saldo actual
  int obtenerSaldo() {
    final box = Hive.box(_boxName);
    return box.get('saldo', defaultValue: 0);
  }

  // Agregar monedas
  Future<void> agregarMonedas(int cantidad) async {
    final box = Hive.box(_boxName);
    final actual = obtenerSaldo();
    await box.put('saldo', actual + cantidad);
  }

  // Gastar monedas (verifica que tenga suficiente)
  bool gastarMonedas(int cantidad) {
    final box = Hive.box(_boxName);
    final actual = obtenerSaldo();
    if (actual >= cantidad) {
      box.put('saldo', actual - cantidad);
      return true;
    }
    return false; // No tiene suficiente
  }

  // Obtener historial de transacciones
  List<Map<String, dynamic>> obtenerHistorial() {
    final box = Hive.box(_boxName);
    final historial = box.get('historial', defaultValue: <Map>[]);
    return List<Map<String, dynamic>>.from(historial);
  }

  // Registrar transacción
  Future<void> _registrarTransaccion(String concepto, int cantidad, String tipo) async {
    final box = Hive.box(_boxName);
    final historial = obtenerHistorial();
    historial.insert(0, {
      'concepto': concepto,
      'cantidad': cantidad,
      'tipo': tipo, // 'ganancia' o 'gasto'
      'fecha': DateTime.now().toIso8601String(),
    });
    // Mantener solo últimas 50
    if (historial.length > 50) historial.removeLast();
    await box.put('historial', historial);
  }

  // Ganar monedas por actividad
  Future<void> ganarPorActividad(String actividad) async {
    int cantidad = 0;
    switch (actividad) {
      case 'diario':
        cantidad = 10;
        break;
      case 'juego':
        cantidad = 5;
        break;
      case 'chat':
        cantidad = 3;
        break;
      case 'modulo':
        cantidad = 8;
        break;
      case 'foto':
        cantidad = 5;
        break;
      default:
        cantidad = 2;
    }
    await agregarMonedas(cantidad);
    await _registrarTransaccion('Actividad: $actividad', cantidad, 'ganancia');
  }

  // Accesorios disponibles
  List<Map<String, dynamic>> obtenerAccesorios() {
    return [
      {'id': 'sombrero', 'nombre': 'Sombrero verde', 'emoji': '👒', 'precio': 20, 'personaje': 'Lola', 'comprado': _tieneAccesorio('sombrero')},
      {'id': 'lentes', 'nombre': 'Lentes cool', 'emoji': '😎', 'precio': 25, 'personaje': 'Lalo', 'comprado': _tieneAccesorio('lentes')},
      {'id': 'capa', 'nombre': 'Capa de Eco Héroe', 'emoji': '🦸', 'precio': 50, 'personaje': 'Lola', 'comprado': _tieneAccesorio('capa')},
      {'id': 'corona', 'nombre': 'Corona de flores', 'emoji': '👑', 'precio': 30, 'personaje': 'Lalo', 'comprado': _tieneAccesorio('corona')},
      {'id': 'botas', 'nombre': 'Botas de lluvia', 'emoji': '👢', 'precio': 15, 'personaje': 'Lola', 'comprado': _tieneAccesorio('botas')},
      {'id': 'mochila', 'nombre': 'Mochila ecológica', 'emoji': '🎒', 'precio': 35, 'personaje': 'Lalo', 'comprado': _tieneAccesorio('mochila')},
    ];
  }

  bool _tieneAccesorio(String id) {
    final box = Hive.box(_boxName);
    return box.get('acc_$id', defaultValue: false);
  }

  Future<bool> comprarAccesorio(String id, int precio) async {
    if (gastarMonedas(precio)) {
      final box = Hive.box(_boxName);
      await box.put('acc_$id', true);
      await _registrarTransaccion('Compra: $id', precio, 'gasto');
      return true;
    }
    return false;
  }

  List<String> obtenerAccesoriosComprados(String personaje) {
    final accesorios = obtenerAccesorios();
    return accesorios
        .where((a) => a['personaje'] == personaje && a['comprado'] == true)
        .map((a) => a['emoji'] as String)
        .toList();
  }
}