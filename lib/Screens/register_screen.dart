
import 'package:sit_and_eat/Model/company_model.dart' as modelComp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:sit_and_eat/Widgets/custom_text.dart';
import 'package:sit_and_eat/Services/auth_service.dart';
import 'package:sit_and_eat/Services/firestore_service.dart';
import 'package:sit_and_eat/Model/user_model.dart' as modelUser;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _nameUserController.dispose();
    _phoneController.dispose();
    _nameRestController.dispose();
    _adressController.dispose();
    _cityController.dispose();
    _zcController.dispose();
    _provinceController.dispose();
    super.dispose();
  }


  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService.instance;
  bool _isPasswordVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameUserController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameRestController = TextEditingController();
  final _cityController = TextEditingController();
  final _zcController = TextEditingController();
  final _adressController = TextEditingController();
  final _provinceController = TextEditingController();

  bool _isCompany = false;
  String? _errorMessage;

  void _handleError(String message){
    setState(() {
      _errorMessage = message;
    });
  }

  void _register() async {
    String? errorMes;
    // controlamos los campos vacios
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty ||
        _nameUserController.text.isEmpty || _phoneController.text.isEmpty) {
      errorMes = "Por favor, completa todos los campos obligatorios";
    } else if (_isCompany && (_nameRestController.text.isEmpty ||
        _adressController.text.isEmpty || _cityController.text.isEmpty
        || _zcController.text.isEmpty)) {
      errorMes = "Porfavor, completa todos los campos de empresa";
    }else if(_passwordController.text.trim().length < 6 ){
      errorMes = "La contraseña debe contener almenos 6 caracteres";
    }
    if (errorMes != null) {
      setState(() {
        _errorMessage = errorMes;
      });
      return;
    }

    try {
      UserCredential? userCredential = await _authService.registerUser(
          _emailController.text.trim(), _passwordController.text.trim());

      if(userCredential.user == null){
        _handleError("No se pudo registrar el usuario.");
        return;
      }
      String uidUser = userCredential.user!.uid;

      modelUser.UserModel newUser = modelUser.UserModel(
        nameUser: _nameUserController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isCompany: _isCompany,
      );

      await _firestoreService.saveData('Usuarios', uidUser, newUser.toMap());
      // parte de empresas
      if (_isCompany) {
        modelComp.CompanyModel newCompany = modelComp.CompanyModel(
          nameRest: _nameRestController.text.trim(),
          address: _adressController.text.trim(),
          city: _cityController.text.trim(),
          zipcode: _zcController.text.trim(),
          province: _provinceController.text.trim(),
        );

        await _firestoreService.saveData('Empresas', uidUser, newCompany.toMap());
      }

      _clearControllers();

      // si se rellenan los campos cambiamos de pantalla
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error en el registro: $e');
      setState(() {
        _handleError(e is FirebaseAuthException
          ? e.message ?? 'Error desconocido' : 'Ocurrió un error inesperado.');
      });
      // borramos datos autentificacion si hay error al registrarse
      if(FirebaseAuth.instance.currentUser != null){
        await FirebaseAuth.instance.currentUser!.delete();
      }
    }
  }

  void _clearControllers(){
    _emailController.clear();
    _passwordController.clear();
    _nameUserController.clear();
    _phoneController.clear();
    _nameRestController.clear();
    _adressController.clear();
    _cityController.clear();
    _zcController.clear();
    _provinceController.clear();
    if(_errorMessage != null){
      setState(() {
        _errorMessage = null;
      });
    }
  }

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Formulario de registro"),
          ),
          body: ListView(
            padding: EdgeInsets.all(screenWidth * 0.06),
            children: [
              CustomTextField(
                  controller: _emailController,
                  labelText: "Correo Electrónico",),
              TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  maxLength: 20,
              decoration: InputDecoration(
                labelText: "Contraseña",
                suffixIcon: IconButton(
                    onPressed: (){
                      setState((){
                        _isPasswordVisible = !_isPasswordVisible;
                });
                },
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                ),
              ),
              ),
              CustomTextField(
                  controller: _nameUserController,
                  labelText: "Nombre y Apellido",),
              CustomTextField(
                  controller: _phoneController,
                  labelText: "Número de contacto", isNumeric: true,
                  maxLength: 9,),
              // casilla activa empresa o no.
              CheckboxListTile(
                title: Text("¿Eres una empresa?"),
                value: _isCompany,
                onChanged: (bool? value) {
                  setState(() {
                    _isCompany = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity
                    .leading, // Coloca el checkbox a la izquierda
              ),
              Text("Activa si tienes negocio de hosteleria"),
              SizedBox(height: 15),
              if (_isCompany)...[
                // datos de base de dades de empresa
                CustomTextField(
                    controller: _nameRestController,
                    labelText: "Nombre del restaurante",),
                CustomTextField(
                    controller: _adressController,
                    labelText: "Dirección",),
                CustomTextField(
                    controller: _cityController,
                    labelText: "Ciudad",),
                CustomTextField(
                    controller: _zcController,
                    labelText: "Código Postal",isNumeric: true,
                    maxLength: 5,),
                CustomTextField(
                    controller: _provinceController,
                    labelText: "Provincia del restaurante",),
              ],
              // crear boto de Registro
              SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: Text("Registrarse"),
              ),
              if(_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red),),
            ],
          ),
        ),
      );
    }
}

