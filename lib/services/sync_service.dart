import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();

  Future<bool> tieneInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> sincronizar() async {
    if (!await tieneInternet()) {
      print('🌐 Sin internet, no se puede sincronizar');
      return;
    }
    print('🔄 Iniciando sincronización...');
    await _sincronizarUsuarios();
    await _sincronizarDiario();
    await _sincronizarVentas();
    await _sincronizarCambiosPassword();
    await _sincronizarLogros();
    await _sincronizarRetos();
    await _sincronizarRecordatorios();
    print('✅ Sincronización completada');
  }

  Future<void> _sincronizarUsuarios() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('usuarios', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var usuario in pendientes) {
      try {
        final result = await ApiService().crearUsuario(
          uid: usuario['uid'],
          nombre: usuario['nombre'],
          nombreUsuario: usuario['nombreUsuario'],
          email: usuario['email'],
          edad: usuario['edad'],
          ciudad: usuario['ciudad'],
          genero: usuario['genero'],
        );
        if (result.ok) {
          pendientes.remove(usuario);
          await box.put('usuarios', pendientes);
          print('✅ Usuario ${usuario['nombreUsuario']} sincronizado');
        }
      } catch (e) {
        print('❌ Error sincronizando usuario: $e');
      }
    }
  }

  Future<void> _sincronizarDiario() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('diario', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var entrada in pendientes) {
      try {
        final result = await ApiService().crearEntradaDiario(
          uid: entrada['uid'],
          nota: entrada['nota'],
          estado: entrada['estado'],
          temperatura: entrada['temperatura'],
          tipoResiduo: entrada['tipoResiduo'],
          compostaPunos: entrada['compostaPunos'],
          lixiviadoCucharadas: entrada['lixiviadoCucharadas'],
        );
        if (result.ok) {
          pendientes.remove(entrada);
          await box.put('diario', pendientes);
          print('✅ Entrada de diario sincronizada');
        }
      } catch (e) {
        print('❌ Error sincronizando diario: $e');
      }
    }
  }

  Future<void> _sincronizarVentas() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('ventas', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var venta in pendientes) {
      try {
        final result = await ApiService().crearVenta(
          uid: venta['uid'],
          producto: venta['producto'],
          cantidad: venta['cantidad'],
          precioUnitario: venta['precioUnitario'],
          totalGanado: venta['totalGanado'],
          descripcion: venta['descripcion'],
        );
        if (result.ok) {
          pendientes.remove(venta);
          await box.put('ventas', pendientes);
          print('✅ Venta sincronizada');
        }
      } catch (e) {
        print('❌ Error sincronizando venta: $e');
      }
    }
  }

  Future<void> guardarCambioPasswordPendiente(Map<String, dynamic> cambio) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('cambios_password', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(cambio);
    await box.put('cambios_password', pendientes);
    print('💾 Cambio de contraseña guardado en pendientes');
  }

  Future<void> _sincronizarCambiosPassword() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('cambios_password', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var cambio in pendientes) {
      try {
        print('💾 Cambio de contraseña para ${cambio['uid']} (solo Hive)');
        pendientes.remove(cambio);
        await box.put('cambios_password', pendientes);
        print('✅ Cambio de contraseña procesado');
      } catch (e) {
        print('❌ Error sincronizando cambio de contraseña: $e');
      }
    }
  }

  Future<void> guardarLogroPendiente(Map<String, dynamic> logro) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('logros', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(logro);
    await box.put('logros', pendientes);
    print('💾 Logro guardado en pendientes');
  }

  Future<void> _sincronizarLogros() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('logros', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var logro in pendientes) {
      try {
        final result = await ApiService().crearLogro(
          uid: logro['uid'],
          tipo: logro['tipo'],
          nombre: logro['nombre'],
          descripcion: logro['descripcion'],
        );
        if (result.ok) {
          pendientes.remove(logro);
          await box.put('logros', pendientes);
          print('✅ Logro sincronizado');
        }
      } catch (e) {
        print('❌ Error sincronizando logro: $e');
      }
    }
  }

  Future<void> guardarRetoPendiente(Map<String, dynamic> reto) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('retos', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(reto);
    await box.put('retos', pendientes);
    print('💾 Reto guardado en pendientes');
  }

  Future<void> _sincronizarRetos() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('retos', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var reto in pendientes) {
      try {
        final result = await ApiService().crearReto(
          uid: reto['uid'],
          retoId: reto['retoId'],
          medicion: reto['medicion'],
          fotoUrl: reto['fotoUrl'],
        );
        if (result.ok) {
          pendientes.remove(reto);
          await box.put('retos', pendientes);
          print('✅ Reto sincronizado');
        }
      } catch (e) {
        print('❌ Error sincronizando reto: $e');
      }
    }
  }

  Future<void> guardarRecordatorioPendiente(Map<String, dynamic> recordatorio) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('recordatorios', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(recordatorio);
    await box.put('recordatorios', pendientes);
    print('💾 Recordatorio guardado en pendientes');
  }

  Future<void> _sincronizarRecordatorios() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('recordatorios', defaultValue: <Map<String, dynamic>>[]);
    if (pendientes.isEmpty) return;
    for (var recordatorio in pendientes) {
      try {
        final result = await ApiService().crearRecordatorio(
          uid: recordatorio['uid'],
          titulo: recordatorio['titulo'],
          mensaje: recordatorio['mensaje'],
        );
        if (result.ok) {
          pendientes.remove(recordatorio);
          await box.put('recordatorios', pendientes);
          print('✅ Recordatorio sincronizado');
        }
      } catch (e) {
        print('❌ Error sincronizando recordatorio: $e');
      }
    }
  }

  Future<void> guardarUsuarioPendiente(Map<String, dynamic> usuario) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('usuarios', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(usuario);
    await box.put('usuarios', pendientes);
    print('💾 Usuario guardado localmente (pendiente de sincronizar)');
  }

  Future<void> guardarDiarioPendiente(Map<String, dynamic> entrada) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('diario', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(entrada);
    await box.put('diario', pendientes);
    print('💾 Entrada de diario guardada localmente (pendiente de sincronizar)');
  }

  Future<void> guardarVentaPendiente(Map<String, dynamic> venta) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('ventas', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(venta);
    await box.put('ventas', pendientes);
    print('💾 Venta guardada localmente (pendiente de sincronizar)');
  }
}