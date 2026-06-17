import 'package:hive_flutter/hive_flutter.dart';

class RecordatoriosService {
  static const String _boxName = 'recordatorios';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // Tipos de recordatorio
  final List<Map<String, dynamic>> _recordatoriosBase = [
    {
      'id': 'alimentacion',
      'titulo': '🍎 Alimentar lombrices',
      'mensaje': '¿Ya les diste de comer a tus lombrices? Recuerda: una vez por semana, en trozos pequeños.',
      'frecuenciaDias': 7,
      'icono': '🍎',
    },
    {
      'id': 'humedad',
      'titulo': '💧 Revisar humedad',
      'mensaje': 'Toca la tierra. Debe sentirse como una esponja exprimida. Si está seca, rocía un poco de agua.',
      'frecuenciaDias': 2,
      'icono': '💧',
    },
    {
      'id': 'foto',
      'titulo': '📸 Foto de progreso',
      'mensaje': 'Toma una foto de tu composta para ver cómo crece. ¡En unos meses verás el cambio!',
      'frecuenciaDias': 5,
      'icono': '📸',
    },
    {
      'id': 'consejo',
      'titulo': '🌱 Consejo ecológico',
      'mensaje': '¿Sabías que las lombrices pueden comer la mitad de su peso en un día? ¡Son súper trabajadoras!',
      'frecuenciaDias': 1,
      'icono': '💡',
    },
  ];

  // Obtener recordatorios pendientes para hoy
  List<Map<String, dynamic>> obtenerPendientes() {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    List<Map<String, dynamic>> pendientes = [];

    for (var recordatorio in _recordatoriosBase) {
      final ultimaVez = _box.get('ultimo_${recordatorio['id']}', defaultValue: '');
      
      if (ultimaVez.isEmpty) {
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
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    await _box.put('ultimo_$id', hoy);
  }

  // Verificar si hay recordatorios pendientes
  bool hayPendientes() {
    return obtenerPendientes().isNotEmpty;
  }

  // Contar pendientes
  int contarPendientes() {
    return obtenerPendientes().length;
  }

  // ✅ Notificación diaria para registrar el diario
  void programarRecordatorioDiario() {
    // Verificar si ya se registró hoy
    final hoy = DateTime.now().toString().substring(0, 10);
    final ultimoRecordatorio = _box.get('ultimo_recordatorio_diario', defaultValue: '');
    
    if (ultimoRecordatorio != hoy) {
      // Guardar que hoy ya se mostró
      _box.put('ultimo_recordatorio_diario', hoy);
      
      // Agregar a pendientes
      final pendientes = _box.get('pendientes', defaultValue: <Map<String, dynamic>>[]);
      pendientes.add({
        'id': 'diario_${DateTime.now().millisecondsSinceEpoch}',
        'titulo': '📝 Registra tu diario',
        'mensaje': '¡No olvides registrar cómo va tu composta hoy! Toma una foto y escribe tu nota. 🌱',
        'icono': '📝',
        'fecha': DateTime.now().toIso8601String(),
      });
      _box.put('pendientes', pendientes);
    }
  }
}