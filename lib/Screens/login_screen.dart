
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sit_and_eat/Screens/register_screen.dart';
import 'package:sit_and_eat/Services/recovPassword.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final RecovPassword recPass= RecovPassword();
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future <void> _login() async {
    if(_emailController.text.isEmpty || _passwordController.text.isEmpty){
      setState(() {
        _errorMessage = 'Complete los campos o Registrese';
      });
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si el inicio de sesión es exitoso, navega a la siguiente pantalla
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );

    } on FirebaseAuthException catch (e) {
      _procesLoginError(e);
    }
  }

  void _procesLoginError(FirebaseAuthException e){
    setState(() {
      if(e.code == 'user-not-found'){
        _errorMessage = 'Email no registrado';
      }else {
        _errorMessage = 'Credenciales incorrectas';
      }
    });
  }

  void _register() async{
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Login'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.07),
        child: Column(
          children: [
            Image.asset('assets/images/logo.png',
            height: 100
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                      onPressed: (){
                        setState((){
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            // boton login para entrar
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _login,
              label: Text('Login', style: TextStyle( fontWeight: FontWeight.bold),),
              icon: Icon(Icons.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text('No tienes cuenta ?'),
            SizedBox(width: 20),
            // crear botón inscribirse
            ElevatedButton.icon(
              onPressed: _register,
              label: Text("Registrarse"),
              icon: Icon(Icons.edit_note),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
            ),
          ],
            ),
            SizedBox(height: 15),
            TextButton(
                onPressed: (){
                  recPass.showPasswordResetDialog(context);
                },
                child: Text('Olvidaste tu contraseña ?'),
            ),
            // mensaje error
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: $_errorMessage',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
