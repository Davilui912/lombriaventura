// lib/services/auth_service.dart
import 'api_service.dart';
import '../models/api_models.dart';

/// Servicio de autenticación SIN Firebase.
/// Usa SOLO tu API FastAPI con nombre de usuario.
class AuthService {
  final ApiService _api = ApiService();
  
  String? _currentUid;
  Usuario? _currentUser;

  String? get currentUid => _currentUid;
  Usuario? get currentUser => _currentUser;

  /// ✅ Getter para verificar autenticación (SOLO UNA VEZ)
  bool get isAuthenticated => _currentUser != null;

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

      // ✅ Usar tu API para crear usuario (con password)
      final result = await _api.crearUsuario(
        uid: nombreUsuario, // Usamos nombreUsuario como ID único
        nombre: nombre,
        nombreUsuario: nombreUsuario,
        email: email,
        password: password, // ✅ AGREGADO
        edad: edad,
        ciudad: ciudad,
        genero: genero,
      );

      if (result.ok) {
        _currentUser = result.data;
        _currentUid = result.data?.uid;
        return (usuario: result.data, error: null);
      } else {
        return (usuario: null, error: result.error);
      }
    } catch (e) {
      return (usuario: null, error: 'Error inesperado: $e');
    }
  }

  /// Login usando SOLO tu API con nombre de usuario y contraseña
  Future<({Usuario? usuario, String? error})> login({
    required String nombreUsuario,
    required String password,
  }) async {
    try {
      // ✅ Usar tu API para autenticar
      final result = await _api.loginUsuario(
        nombreUsuario: nombreUsuario,
        password: password,
      );
      
      if (result.ok) {
        _currentUser = result.data;
        _currentUid = result.data?.uid;
        return (usuario: result.data, error: null);
      } else {
        return (usuario: null, error: result.error);
      }
    } catch (e) {
      return (usuario: null, error: 'Error inesperado: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    _currentUid = null;
  }

  /// Obtener usuario actual
  Usuario? get usuarioActual => _currentUser;
}