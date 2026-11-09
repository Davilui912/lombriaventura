import 'package:hive_flutter/hive_flutter.dart';

class ActividadService {
  static const String _boxName = 'actividad';

  //   Clave donde se guarda el récord de días
  static const String _recordKey = 'record_dias';

  Future<void> _guardarEntrada() async {
    final box = Hive.box(_boxName);
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    await box.put(hoy, true);
  }

  // Registrar actividad hoy
  Future<void> registrarActividad() async {
    await _guardarEntrada();
  }

  // Obtener total de días activos
  int obtenerDiasActivos() {
    final box = Hive.box(_boxName);
    //   Excluimos la clave del récord para que no cuente como día activo
    return box.keys.where((k) => k != _recordKey).length;
  }

  // Obtener días consecutivos (racha actual)
  int obtenerRacha() {
    final box = Hive.box(_boxName);
    int racha = 0;
    DateTime fecha = DateTime.now();

    while (true) {
      final key = fecha.toIso8601String().split('T')[0];
      if (box.get(key, defaultValue: false)) {
        racha++;
        fecha = fecha.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return racha;
  }

  //   NUEVO: Obtener el récord guardado
  int obtenerRecord() {
    final box = Hive.box(_boxName);
    return box.get(_recordKey, defaultValue: 0);
  }

  //   NUEVO: Actualizar el récord si la racha actual es mayor
  Future<void> actualizarRecordSiEsNecesario() async {
    final box = Hive.box(_boxName);
    final rachaActual = obtenerRacha();
    final recordActual = obtenerRecord();

    if (rachaActual > recordActual) {
      await box.put(_recordKey, rachaActual);
      print('🏆 ¡Nuevo récord! $rachaActual días');
    }
  }

  //   NUEVO: Obtener racha y récord en un solo paso (actualiza el récord si hace falta)
  Future<Map<String, int>> obtenerRachaYRecord() async {
    await actualizarRecordSiEsNecesario();
    return {
      'racha': obtenerRacha(),
      'record': obtenerRecord(),
    };
  }

  // Obtener fase de Max según días activos
  Map<String, dynamic> obtenerFaseMax() {
    final dias = obtenerDiasActivos();

    if (dias >= 31) {
      return {
        'fase': 5,
        'nombre': 'Max Manzanero',
        'emoji': '🌲',
        'altura': 200,
        'descripcion': '¡Soy un árbol adulto! Doy manzanas y sombra.',
      };
    } else if (dias >= 15) {
      return {
        'fase': 4,
        'nombre': 'Max Joven',
        'emoji': '🌳',
        'altura': 80,
        'descripcion': '¡Estoy creciendo fuerte! Mis ramas se extienden.',
      };
    } else if (dias >= 8) {
      return {
        'fase': 3,
        'nombre': 'Pequeño Max',
        'emoji': '🪴',
        'altura': 30,
        'descripcion': '¡Ya tengo hojitas! Necesito sol y agua.',
      };
    } else if (dias >= 4) {
      return {
        'fase': 2,
        'nombre': 'Brotesito',
        'emoji': '🌱',
        'altura': 10,
        'descripcion': '¡Estoy brotando! Apenas salgo de la tierra.',
      };
    } else {
      return {
        'fase': 1,
        'nombre': 'Semillita',
        'emoji': '🌰',
        'altura': 0,
        'descripcion': 'Soy una semilla. ¡Cuídame para que crezca!',
      };
    }
  }
}