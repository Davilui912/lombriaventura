import 'package:hive_flutter/hive_flutter.dart';

class RecordatoriosService {
  static const String _boxName = 'recordatorios';

  // Tipos de recordatorio
  final List<Map<String, dynamic>> _recordatoriosBase = [
    {
      'id': 'alimentacion',
      'titulo': '🍎 Alimentar lombrices',
      'mensaje': '¿Ya les diste de comer a tus lombrices? Recuerda: una vez por semana, en trozos pequeños.',
      'frecuenciaDias': 7, // Cada 7 días
      'icono': '🍎',
    },
    {
      'id': 'humedad',
      'titulo': '💧 Revisar humedad',
      'mensaje': 'Toca la tierra. Debe sentirse como una esponja exprimida. Si está seca, rocía un poco de agua.',
      'frecuenciaDias': 2, // Cada 2 días
      'icono': '💧',
    },
    {
      'id': 'foto',
      'titulo': '📸 Foto de progreso',
      'mensaje': 'Toma una foto de tu composta para ver cómo crece. ¡En unos meses verás el cambio!',
      'frecuenciaDias': 5, // Cada 5 días
      'icono': '📸',
    },
    {
      'id': 'consejo',
      'titulo': '🌱 Consejo ecológico',
      'mensaje': '¿Sabías que las lombrices pueden comer la mitad de su peso en un día? ¡Son súper trabajadoras!',
      'frecuenciaDias': 1, // Cada día
      'icono': '💡',
    },
  ];

  // Obtener recordatorios pendientes para hoy
  List<Map<String, dynamic>> obtenerPendientes() {
    final box = Hive.box(_boxName);
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    List<Map<String, dynamic>> pendientes = [];

    for (var recordatorio in _recordatoriosBase) {
      final ultimaVez = box.get('ultimo_${recordatorio['id']}', defaultValue: '');
      
      if (ultimaVez.isEmpty) {
        // Nunca se ha mostrado, es pendiente
        pendientes.add(recordatorio);
      } else {
        final ultimaFecha = DateTime.parse(ultimaVez);
        final diferencia = DateTime.now().difference(ultimaFecha).inDays;
        
        if (diferencia >= (recordatorio['frecuenciaDias'] as int)) {
          pendientes.add(recordatorio);
        }
      }
    }

    return pendientes;
  }

  // Marcar recordatorio como visto
  Future<void> marcarVisto(String id) async {
    final box = Hive.box(_boxName);
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    await box.put('ultimo_$id', hoy);
  }

  // Verificar si hay recordatorios pendientes
  bool hayPendientes() {
    return obtenerPendientes().isNotEmpty;
  }

  // Contar pendientes
  int contarPendientes() {
    return obtenerPendientes().length;
  }
}