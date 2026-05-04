import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instancia de FirebaseAuth para comunicarnos con el servidor
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Método para registrar un nuevo usuario (lo usaremos pronto)
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error de Firebase Auth: ${e.code}');
      return null;
    } catch (e) {
      print('Error general: $e');
      return null;
    }
  }
}
