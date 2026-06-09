import 'package:hive_flutter/hive_flutter.dart';
import 'monedas_service.dart';

class AccesoriosService {
  late Box _box;
  
  Future<void> init() async {
    _box = await Hive.openBox('accesorios');
  }
  
  Set<String> obtenerComprados(String personaje) {
    final lista = _box.get('${personaje}_comprados', defaultValue: <String>[]);
    return Set<String>.from(lista);
  }
  
  Map<String, String?> obtenerEquipados(String personaje) {
    return {
      'gorra': _box.get('${personaje}_gorra'),
      'lentes': _box.get('${personaje}_lentes'),
      'collar': _box.get('${personaje}_collar'),
      'sombrero': _box.get('${personaje}_sombrero'),
    };
  }
  
  Future<bool> comprarAccesorio(String personaje, String id, int precio) async {
    final monedasService = MonedasService();
    await monedasService.init();
    
    if (await monedasService.gastarMonedas(precio)) {
      final comprados = obtenerComprados(personaje);
      comprados.add(id);
      await _box.put('${personaje}_comprados', comprados.toList());
      return true;
    }
    return false;
  }
  
  Future<void> equiparAccesorio(String personaje, String? gorra, String? lentes, String? collar, String? sombrero) async {
    await _box.put('${personaje}_gorra', gorra);
    await _box.put('${personaje}_lentes', lentes);
    await _box.put('${personaje}_collar', collar);
    await _box.put('${personaje}_sombrero', sombrero);
  }
}