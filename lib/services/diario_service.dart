import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/entrada_diario.dart';

class DiarioService {
  static const String _boxName = 'diario';
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Obtener todas las entradas ordenadas por fecha (más reciente primero)
  List<EntradaDiario> obtenerEntradas() {
    final box = Hive.box(_boxName);
    final entradas = box.values.map((e) => EntradaDiario.fromMap(Map<String, dynamic>.from(e))).toList();
    entradas.sort((a, b) => b.fecha.compareTo(a.fecha));
    return entradas;
  }

  // Tomar foto con la cámara
  Future<String?> tomarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (foto != null) {
        return await _guardarFotoLocal(foto);
      }
    } catch (e) {
      print('Error al tomar foto: $e');
    }
    return null;
  }

  // Seleccionar foto de galería
  Future<String?> seleccionarDeGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (foto != null) {
        return await _guardarFotoLocal(foto);
      }
    } catch (e) {
      print('Error al seleccionar foto: $e');
    }
    return null;
  }

  // Guardar foto en almacenamiento local
  Future<String> _guardarFotoLocal(XFile foto) async {
    final directory = await getApplicationDocumentsDirectory();
    final nombreArchivo = 'composta_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final archivoGuardado = File('${directory.path}/$nombreArchivo');
    await archivoGuardado.writeAsBytes(await foto.readAsBytes());
    return archivoGuardado.path;
  }

  // Guardar nueva entrada (temperatura ahora es String)
  Future<void> guardarEntrada({
    required List<String> fotosRutas,
    String? nota,
    String estado = '😊',
    int? humedad,
    String? temperatura, // ← CAMBIADO a String
    String? tipoResiduo,
    double? produccionComposta,
    double? produccionLixiviado,
  }) async {
    final box = Hive.box(_boxName);
    final entrada = EntradaDiario(
      id: _uuid.v4(),
      fecha: DateTime.now(),
      nota: nota,
      fotosRutas: fotosRutas,
      estado: estado,
      humedad: humedad,
      temperatura: temperatura,
      tipoResiduo: tipoResiduo,
      produccionComposta: produccionComposta,
      produccionLixiviado: produccionLixiviado,
    );
    await box.put(entrada.id, entrada.toMap());
  }

  // Eliminar una entrada
  Future<void> eliminarEntrada(String id) async {
    final box = Hive.box(_boxName);
    final entrada = box.get(id);
    if (entrada != null) {
      final entradaObj = EntradaDiario.fromMap(Map<String, dynamic>.from(entrada));
      // Eliminar archivos de fotos
      for (var ruta in entradaObj.fotosRutas) {
        final archivo = File(ruta);
        if (await archivo.exists()) {
          await archivo.delete();
        }
      }
      await box.delete(id);
    }
  }

  // Obtener conteo de fotos totales
  int obtenerTotalFotos() {
    final entradas = obtenerEntradas();
    int total = 0;
    for (var entrada in entradas) {
      total += entrada.fotosRutas.length;
    }
    return total;
  }
}