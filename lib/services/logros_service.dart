import 'package:hive_flutter/hive_flutter.dart';

class LogrosService {
  static const String _boxName = 'logros';

  // Lista de todas las insignias del juego
  final List<Map<String, dynamic>> _todasLasInsignias = [
    {
      'id': 'chat_lola',
      'nombre': 'Amigo Lombriz',
      'emoji': '🪱',
      'descripcion': 'Habla con Lola en el chat',
      'categoria': 'Social',
    },
    {
      'id': 'primera_foto',
      'nombre': 'Fotógrafo',
      'emoji': '📸',
      'descripcion': 'Toma tu primera foto de la composta',
      'categoria': 'Diario',
    },
    {
      'id': 'clasificador',
      'nombre': 'Clasificador',
      'emoji': '♻️',
      'descripcion': 'Completa el juego de clasificar',
      'categoria': 'Juegos',
    },
    {
      'id': 'memorion',
      'nombre': 'Memorión',
      'emoji': '🧠',
      'descripcion': 'Completa el memorama',
      'categoria': 'Juegos',
    },
    {
      'id': 'alimentador',
      'nombre': 'Alimentador',
      'emoji': '🍎',
      'descripcion': 'Alimenta bien a Lola',
      'categoria': 'Juegos',
    },
    {
      'id': 'eco_heroe',
      'nombre': 'Eco Héroe',
      'emoji': '🌱',
      'descripcion': '¡Consigue todas las insignias!',
      'categoria': 'Especial',
    },
  ];

  // Obtener todas las insignias con su estado
  List<Map<String, dynamic>> obtenerInsignias() {
    final box = Hive.box(_boxName);
    return _todasLasInsignias.map((insignia) {
      final ganada = box.get(insignia['id'], defaultValue: false);
      return {
        ...insignia,
        'ganada': ganada,
      };
    }).toList();
  }

  // Desbloquear una insignia
  Future<void> desbloquearInsignia(String id) async {
    final box = Hive.box(_boxName);
    await box.put(id, true);
  }

  // Verificar si una insignia está desbloqueada
  bool estaDesbloqueada(String id) {
    final box = Hive.box(_boxName);
    return box.get(id, defaultValue: false);
  }

  // Contar insignias ganadas
  int contarInsigniasGanadas() {
    final box = Hive.box(_boxName);
    int count = 0;
    for (var insignia in _todasLasInsignias) {
      if (box.get(insignia['id'], defaultValue: false)) {
        count++;
      }
    }
    return count;
  }

  // Total de insignias
  int get totalInsignias => _todasLasInsignias.length;

  // Obtener estrellas (cada insignia vale 5 estrellas)
  int obtenerEstrellas() {
    return contarInsigniasGanadas() * 5;
  }

  // Verificar si ya es Eco Héroe
  bool esEcoHeroe() {
    final ganadas = contarInsigniasGanadas();
    // Eco Héroe se gana al tener todas las demás (5 insignias)
    return ganadas >= 5;
  }
}