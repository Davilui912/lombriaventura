import 'package:hive_flutter/hive_flutter.dart';
import 'api_service.dart';
import 'sync_service.dart';
import '../models/api_models.dart';

class AuthService {
  final ApiService _api = ApiService();
  final SyncService _syncService = SyncService();
  
  String? _currentUid;
  Usuario? _currentUser;

  String? get currentUid => _currentUid;
  Usuario? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // ─── OBTENER USUARIO DESDE HIVE ───

  /// Obtener usuario actual desde Hive
  Future<Usuario?> obtenerUsuarioDesdeHive() async {
    try {
      final box = await Hive.openBox('configuracion');
      final uid = box.get('usuario_uid');
      final nombre = box.get('usuario_nombre');
      final nombreUsuario = box.get('usuario_actual');
      final email = box.get('usuario_email');
      final password = box.get('usuario_password');
      final edad = box.get('usuario_edad');
      final ciudad = box.get('usuario_ciudad');

      if (nombreUsuario != null) {
        return Usuario(
          uid: uid ?? '',
          nombre: nombre ?? '',
          nombreUsuario: nombreUsuario,
          email: email ?? '',
          password: password ?? '',
          edad: edad != null ? int.tryParse(edad.toString()) : null,
          ciudad: ciudad,
        );
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario de Hive: $e');
      return null;
    }
  }

  // ─── REGISTRO ───

  /// Registro de usuario usando SOLO tu API
  Future<({Usuario? usuario, String? error})> registrar({
    required String nombre,
    required String nombreUsuario,
    required String password,
    required String email,
    int? edad,
    String? ciudad,
    String? genero,
  }) async {
    try {
      // Verificar si el usuario ya existe
      final existe = await _api.obtenerUsuario(nombreUsuario);
      if (existe.ok) {
        return (usuario: null, error: 'El nombre de usuario ya está registrado');
      }

      // ✅ Guardar en Hive primero (con contraseña)
      final box = await Hive.openBox('configuracion');
      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      
      await box.put('usuario_uid', uid);
      await box.put('usuario_actual', nombreUsuario);
      await box.put('usuario_nombre', nombre);
      await box.put('usuario_password', password);
      await box.put('usuario_email', email);
      if (edad != null) await box.put('usuario_edad', edad.toString());
      if (ciudad != null) await box.put('usuario_ciudad', ciudad);
      await box.put('login_exitoso', true);

      // ✅ Guardar en API (SIN contraseña)
      final result = await _api.crearUsuario(
        uid: uid,
        nombre: nombre,
        nombreUsuario: nombreUsuario,
        email: email,
        edad: edad,
        ciudad: ciudad,
        genero: genero,
      );

      if (result.ok) {
        // Crear usuario con datos de API + contraseña de Hive
        final usuario = Usuario(
          uid: uid,
          nombre: nombre,
          nombreUsuario: nombreUsuario,
          email: email,
          password: password,
          edad: edad,
          ciudad: ciudad,
          genero: genero,
        );
        _currentUser = usuario;
        _currentUid = uid;
        return (usuario: usuario, error: null);
      } else {
        // Si API falla, guardar en pendientes
        await _syncService.guardarUsuarioPendiente({
          'uid': uid,
          'nombre': nombre,
          'nombreUsuario': nombreUsuario,
          'email': email,
          'edad': edad,
          'ciudad': ciudad,
          'genero': genero,
        });
        print('💾 Usuario guardado en pendientes (API falló)');
        
        final usuario = Usuario(
          uid: uid,
          nombre: nombre,
          nombreUsuario: nombreUsuario,
          email: email,
          password: password,
          edad: edad,
          ciudad: ciudad,
          genero: genero,
        );
        _currentUser = usuario;
        _currentUid = uid;
        return (usuario: usuario, error: null);
      }
    } catch (e) {
      return (usuario: null, error: 'Error inesperado: $e');
    }
  }

  // ─── LOGIN ───

  /// Login con sincronización Hive → API
  Future<({Usuario? usuario, String? error})> login({
    required String nombreUsuario,
    required String password,
  }) async {
    try {
      // 1. Buscar en Hive primero
      final box = await Hive.openBox('configuracion');
      final usuarioGuardado = box.get('usuario_actual');
      final passwordGuardada = box.get('usuario_password');

      print('🔍 Buscando en Hive: usuario=$usuarioGuardado');

      // 2. Validar en Hive
      if (usuarioGuardado == nombreUsuario && passwordGuardada == password) {
        print('✅ Contraseña válida desde Hive');
        
        // 3. Obtener datos de API
        final result = await _api.obtenerUsuario(nombreUsuario);
        
        if (result.ok && result.data != null) {
          final usuarioApi = result.data!;
          
          // ✅ Combinar: datos API + contraseña Hive
          final usuario = Usuario(
            uid: usuarioApi.uid,
            nombre: usuarioApi.nombre,
            nombreUsuario: usuarioApi.nombreUsuario,
            email: usuarioApi.email,
            password: password, // ✅ Desde Hive
            edad: usuarioApi.edad,
            ciudad: usuarioApi.ciudad,
            genero: usuarioApi.genero,
          );
          
          _currentUser = usuario;
          _currentUid = usuario.uid;
          await box.put('login_exitoso', true);
          return (usuario: usuario, error: null);
        } else {
          // Si API no responde, usar datos de Hive
          final usuario = await obtenerUsuarioDesdeHive();
          if (usuario != null) {
            _currentUser = usuario;
            _currentUid = usuario.uid;
            return (usuario: usuario, error: null);
          }
        }
      }

      // 4. Si no está en Hive, buscar en API y guardar en Hive
      if (await _syncService.tieneInternet()) {
        final result = await _api.obtenerUsuario(nombreUsuario);
        
        if (result.ok && result.data != null) {
          final usuarioApi = result.data!;
          
          // Guardar en Hive con la contraseña ingresada
          await box.put('usuario_uid', usuarioApi.uid);
          await box.put('usuario_actual', usuarioApi.nombreUsuario);
          await box.put('usuario_nombre', usuarioApi.nombre);
          await box.put('usuario_password', password);
          await box.put('usuario_email', usuarioApi.email);
          if (usuarioApi.edad != null) await box.put('usuario_edad', usuarioApi.edad.toString());
          if (usuarioApi.ciudad != null) await box.put('usuario_ciudad', usuarioApi.ciudad);
          await box.put('login_exitoso', true);

          final usuario = Usuario(
            uid: usuarioApi.uid,
            nombre: usuarioApi.nombre,
            nombreUsuario: usuarioApi.nombreUsuario,
            email: usuarioApi.email,
            password: password,
            edad: usuarioApi.edad,
            ciudad: usuarioApi.ciudad,
            genero: usuarioApi.genero,
          );
          
          _currentUser = usuario;
          _currentUid = usuario.uid;
          print('✅ Usuario guardado en Hive desde API');
          return (usuario: usuario, error: null);
        }
      }

      return (usuario: null, error: 'Usuario o contraseña incorrectos');
    } catch (e) {
      return (usuario: null, error: 'Error inesperado: $e');
    }
  }

  // ─── CAMBIAR CONTRASEÑA ───

  /// Cambiar contraseña (SOLO en Hive)
  Future<({bool success, String? error})> cambiarPassword({
    required String nuevaPassword,
  }) async {
    try {
      if (_currentUser == null) {
        return (success: false, error: 'No hay usuario autenticado');
      }

      final box = await Hive.openBox('configuracion');

      // 1. Validar longitud mínima
      if (nuevaPassword.length < 4) {
        return (success: false, error: 'La contraseña debe tener al menos 4 caracteres');
      }

      // 2. Actualizar en Hive
      await box.put('usuario_password', nuevaPassword);
      print('✅ Contraseña actualizada en Hive');

      // 3. Actualizar objeto local
      _currentUser = Usuario(
        uid: _currentUser!.uid,
        nombre: _currentUser!.nombre,
        nombreUsuario: _currentUser!.nombreUsuario,
        email: _currentUser!.email,
        password: nuevaPassword,
        edad: _currentUser!.edad,
        ciudad: _currentUser!.ciudad,
        genero: _currentUser!.genero,
      );

      // 4. Guardar pendiente para sincronizar en otros dispositivos
      await _syncService.guardarCambioPasswordPendiente({
        'uid': _currentUser!.uid,
        'nueva_password': nuevaPassword,
      });
      print('💾 Cambio de contraseña guardado en pendientes');

      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Error al cambiar contraseña: $e');
    }
  }

  // ─── VERIFICAR RESPUESTA DE SEGURIDAD ───

  /// Verificar respuesta de seguridad del usuario
  Future<bool> verificarRespuestaSeguridad(String respuesta) async {
    try {
      final box = await Hive.openBox('configuracion');
      final respuestaGuardada = box.get('usuario_respuesta_seguridad');
      return respuestaGuardada == respuesta;
    } catch (e) {
      print('❌ Error verificando respuesta de seguridad: $e');
      return false;
    }
  }

  // ─── SINCRONIZAR PENDIENTES ───

  /// Sincronizar cambios pendientes desde Hive a API
  Future<void> syncPendientes() async {
    if (await _syncService.tieneInternet()) {
      await _syncService.sincronizar();
    }
  }

  // ─── LOGOUT ───

  /// Cerrar sesión
  Future<void> logout() async {
    final box = await Hive.openBox('configuracion');
    await box.put('login_exitoso', false);
    _currentUser = null;
    _currentUid = null;
  }

  // ─── GETTERS ───

  /// Obtener usuario actual
  Usuario? get usuarioActual => _currentUser;
}