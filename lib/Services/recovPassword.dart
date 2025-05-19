
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecovPassword{
  final FirebaseAuth _auth= FirebaseAuth.instance;

  Future<void> checkPasswordResetLink(String url) async{
    try{
      bool isLinkValid = _auth.isSignInWithEmailLink(url);

      if(isLinkValid){
        print('Todo correcto');
      }
    }catch (e){
      print('Error al verificar el enlace: $e');
    }
  }

  Future<void> resetPassword(String email,String newPassword, String oobCode) async{
    try{
      await _auth.confirmPasswordReset(
          code: oobCode,
          newPassword: newPassword,
      );
      print('Contraseña restablecida exitosamente');
    }catch (e){
      print('Error al restablecer la contraseña: $e');
    }
  }

  Future <void> sendPasswordResetEmail(BuildContext context, String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tienes un correo de recuperación')),
      );
    } on FirebaseAuthException catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Ocurrio un error')),
      );
    }
  }

  void showPasswordResetDialog(BuildContext context){
    TextEditingController emailController = TextEditingController();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Recuperación de Contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: (){
                  String email = emailController.text.trim();
                  if(email.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor ingresa email registrado')),
                    );
                  }else{
                    sendPasswordResetEmail(context,email);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Enviar enlace'),
              ),
            ],
          );
        }
    );
  }

}