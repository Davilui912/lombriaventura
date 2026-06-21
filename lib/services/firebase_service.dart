import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== AUTENTICACIÓN ==========
  
  static Future<User?> registrarUsuario(String email, String password, String nombre) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Actualizar displayName
      await credential.user?.updateDisplayName(nombre);
      
      // Guardar información adicional del usuario en Firestore
      await _firestore.collection('usuarios').doc(credential.user!.uid).set({
        'nombre': nombre,
        'email': email,
        'fechaRegistro': DateTime.now().toIso8601String(),
        'uid': credential.user!.uid,
      }, SetOptions(merge: true));
      
      return credential.user;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  static Future<User?> iniciarSesion(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  static Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  static User? get usuarioActual => _auth.currentUser;

  // ========== FIRESTORE ==========
  
  static Future<void> guardarDato(String coleccion, String documento, Map<String, dynamic> data) async {
    await _firestore.collection(coleccion).doc(documento).set(data, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> obtenerDato(String coleccion, String documento) async {
    final doc = await _firestore.collection(coleccion).doc(documento).get();
    return doc.data();
  }

  static Future<List<Map<String, dynamic>>> obtenerLista(String coleccion) async {
    final query = await _firestore.collection(coleccion).get();
    return query.docs.map((doc) => doc.data()).toList();
  }
}