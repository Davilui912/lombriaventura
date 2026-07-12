import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Verificar si hay internet
  Future<bool> tieneInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Sincronizar datos pendientes con la API
  Future<void> sincronizar() async {
    if (!await tieneInternet()) {
      print('🌐 Sin internet, no se puede sincronizar');
      return;
    }

    print('🔄 Iniciando sincronización...');

    // 1. Sincronizar usuarios pendientes
    await _sincronizarUsuarios();

    // 2. Sincronizar diario pendiente
    await _sincronizarDiario();

    // 3. Sincronizar ventas pendientes
    await _sincronizarVentas();

    print('✅ Sincronización completada');
  }

  /// Sincronizar usuarios pendientes
  Future<void> _sincronizarUsuarios() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('usuarios', defaultValue: <Map<String, dynamic>>[]);

    if (pendientes.isEmpty) return;

    print('📤 Sincronizando ${pendientes.length} usuarios pendientes...');

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
          // ✅ Eliminar de pendientes
          pendientes.remove(usuario);
          await box.put('usuarios', pendientes);
          print('✅ Usuario ${usuario['nombreUsuario']} sincronizado');
        }
      } catch (e) {
        print('❌ Error sincronizando usuario: $e');
      }
    }
  }

  /// Sincronizar diario pendiente
  Future<void> _sincronizarDiario() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('diario', defaultValue: <Map<String, dynamic>>[]);

    if (pendientes.isEmpty) return;

    print('📤 Sincronizando ${pendientes.length} entradas de diario...');

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

  /// Sincronizar ventas pendientes
  Future<void> _sincronizarVentas() async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('ventas', defaultValue: <Map<String, dynamic>>[]);

    if (pendientes.isEmpty) return;

    print('📤 Sincronizando ${pendientes.length} ventas pendientes...');

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

  /// Guardar usuario pendiente de sincronización
  Future<void> guardarUsuarioPendiente(Map<String, dynamic> usuario) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('usuarios', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(usuario);
    await box.put('usuarios', pendientes);
    print('💾 Usuario guardado localmente (pendiente de sincronizar)');
  }

  /// Guardar diario pendiente de sincronización
  Future<void> guardarDiarioPendiente(Map<String, dynamic> entrada) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('diario', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(entrada);
    await box.put('diario', pendientes);
    print('💾 Entrada de diario guardada localmente (pendiente de sincronizar)');
  }

  /// Guardar venta pendiente de sincronización
  Future<void> guardarVentaPendiente(Map<String, dynamic> venta) async {
    final box = await Hive.openBox('sync_pendientes');
    final pendientes = box.get('ventas', defaultValue: <Map<String, dynamic>>[]);
    pendientes.add(venta);
    await box.put('ventas', pendientes);
    print('💾 Venta guardada localmente (pendiente de sincronizar)');
  }
}