
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registerUser(String email, String password) async {
    try{
      UserCredential userCredential= await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password.trim(),
      );

      await userCredential.user?.sendEmailVerification();

      return userCredential;

    }on FirebaseAuthException catch (e){
      if(e.code == 'email-already-in-use'){
        throw Exception('El correo ya está registrado.');
      }else if(e.code == 'weak-password'){
        throw Exception('La contraseña es debil.');
      }else if(e.code == 'invalid-email'){
        throw Exception('El formato del correo no es valido.');
      }else{
        throw Exception('Error al registrar usuario: ${e.message}');
      }
    }
  }

}
