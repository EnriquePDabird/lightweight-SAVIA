import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instancia de FirebaseAuth para comunicarnos con el servidor
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para iniciar sesión
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Firebase intenta hacer el login
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // Si tiene éxito, devuelve el usuario
    } on FirebaseAuthException catch (e) {
      // Aquí puedes capturar errores específicos (ej. contraseña incorrecta)
      print('Error de Firebase Auth: ${e.code}');
      return null;
    } catch (e) {
      print('Error general: $e');
      return null;
    }
  }
}
