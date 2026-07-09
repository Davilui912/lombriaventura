import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import '../models/api_models.dart';

/// Conecta Firebase Auth con tu API FastAPI.
///
/// Flujo de registro:
///   1. Firebase crea la cuenta y devuelve un uid.
///   2. Usamos ese mismo uid para crear el usuario en PostgreSQL.
///
/// Flujo de login:
///   1. Firebase autentica y devuelve el uid.
///   2. Consultamos el perfil completo desde PostgreSQL.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _api = ApiService();

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  // ─── Registro

  /// Crea cuenta en Firebase y luego registra el usuario en PostgreSQL.
  /// Devuelve el [Usuario] creado, o un mensaje de error como String.
  Future<({Usuario? usuario, String? error})> registrar({
    required String email,
    required String password,
    required String nombre,
    required String nombreUsuario,
    int? edad,
    String? ciudad,
    String? genero,
  }) async {
    try {
      // 1. Crear cuenta en Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // 2. Crear usuario en PostgreSQL usando el mismo uid de Firebase
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
        return (usuario: result.data, error: null);
      } else {
        // Si falla el registro en PostgreSQL, eliminamos la cuenta de Firebase
        // para no dejar usuarios huérfanos.
        await cred.user?.delete();
        return (usuario: null, error: result.error);
      }
    } on FirebaseAuthException catch (e) {
      return (usuario: null, error: _mensajeFirebase(e.code));
    } catch (e) {
      return (usuario: null, error: 'Error inesperado: $e');
    }
  }

  // ─── Login
  /// Inicia sesión en Firebase y obtiene el perfil completo desde PostgreSQL.
  Future<({Usuario? usuario, String? error})> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      final result = await _api.obtenerUsuario(uid);
      if (result.ok) {
        return (usuario: result.data, error: null);
      }
      return (usuario: null, error: result.error);
    } on FirebaseAuthException catch (e) {
      return (usuario: null, error: _mensajeFirebase(e.code));
    } catch (e) {
      return (usuario: null, error: 'Error inesperado: $e');
    }
  }

  // ─── Logout

  Future<void> logout() => _auth.signOut();

  // ─── Mensajes de error amigables

  String _mensajeFirebase(String code) => switch (code) {
        'email-already-in-use' => 'Ese correo ya está registrado.',
        'invalid-email' => 'El correo no es válido.',
        'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
        'user-not-found' => 'No encontramos una cuenta con ese correo.',
        'wrong-password' => 'Contraseña incorrecta.',
        'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
        _ => 'Error de autenticación ($code).',
      };
}
