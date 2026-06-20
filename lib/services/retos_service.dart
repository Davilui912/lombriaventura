import 'package:hive_flutter/hive_flutter.dart';
import '../models/reto.dart';

class RetosService {
  static const String _boxName = 'retos';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _inicializarRetos();
  }

  void _inicializarRetos() {
    if (_box.isEmpty) {
      final List<Reto> retosIniciales = [
        Reto(
          id: 'reto_1',
          titulo: 'Obtener lombrices',
          descripcion: 'Consigue lombrices para empezar tu lombricomposta.',
          emoji: '🎯',
          orden: 1,
        ),
        Reto(
          id: 'reto_2',
          titulo: 'Construir ecosistema',
          descripcion: 'Construye el hogar de tus lombrices y toma una foto.',
          emoji: '🏠',
          orden: 2,
        ),
        // ✅ NUEVOS RETOS MENSUALES
        Reto(
          id: 'reto_humus',
          titulo: '📸 Producir humus',
          descripcion: 'Toma una foto de tu humus y mide cuántos puños produjiste.\n(Disponible el día 1 de cada mes)',
          emoji: '🌱',
          orden: 3,
        ),
        Reto(
          id: 'reto_lixiviado',
          titulo: '📸 Producir lixiviado',
          descripcion: 'Toma una foto de tu lixiviado y mide cuántas cucharadas recolectaste.\n(Disponible el día 1 de cada mes)',
          emoji: '💧',
          orden: 4,
        ),
      ];

      for (var reto in retosIniciales) {
        _box.put(reto.id, reto.toMap());
      }
    }
  }

  List<Reto> obtenerRetos() {
    final List<Reto> retos = [];
    for (var key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        retos.add(Reto.fromMap(Map<String, dynamic>.from(data)));
      }
    }
    retos.sort((a, b) => a.orden.compareTo(b.orden));
    return retos;
  }

  Reto? obtenerRetoPorId(String id) {
    final data = _box.get(id);
    if (data != null) {
      return Reto.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> completarReto(String id) async {
    final data = _box.get(id);
    if (data != null) {
      final reto = Reto.fromMap(Map<String, dynamic>.from(data));
      reto.completado = true;
      await _box.put(id, reto.toMap());
    }
  }

  bool estaCompletado(String id) {
    final data = _box.get(id);
    if (data != null) {
      final reto = Reto.fromMap(Map<String, dynamic>.from(data));
      return reto.completado;
    }
    return false;
  }

  int obtenerProgreso() {
    final retos = obtenerRetos();
    final completados = retos.where((r) => r.completado).length;
    return (completados / retos.length * 100).round();
  }
}