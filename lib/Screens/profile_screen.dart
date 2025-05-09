
import 'package:sit_and_eat/Model/company_model.dart';
import 'package:sit_and_eat/Screens/edit_profile_screen.dart';
import 'package:sit_and_eat/Screens/login_screen.dart';
import 'package:sit_and_eat/Services/company_service.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sit_and_eat/Model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});


  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _user = UserService();
  late String userId;
  final CompanyService _local = CompanyService();

@override
void initState(){
  super.initState();
  userId = _auth.currentUser?.uid ?? '';
}

void _signOut() async{
  try{
    await _auth.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }catch (e){
    print('Error al cerrar Sesión: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al Cerrar Sesión')),
    );
  }
}

Future<void> _editProfile(UserModel user, List<CompanyModel> companies)async{
  final result = await Navigator.push(context,
    MaterialPageRoute(builder: (context) => EditProfileScreen(
      user: user, userId: userId,
        comp: companies.isNotEmpty ? companies.first : null),
  ),
  );

  if(result != null){
    setState(() {
      if(result['updatedUser'] != null){
        user = result['updatedUser'] as UserModel;
      }
      if(result['updatedCompany'] != null){
        if(companies.isNotEmpty){
          companies[0] = result['updatedCompany'] as CompanyModel;
        }else{
          companies.add(result['updatedCompany'] as CompanyModel);
        }
      }
    });
  }
}
Stream<List<CompanyModel>> _getListEmpresasByUsu(String uidUser, bool isCompany) {
  if(isCompany){
  return _local.getCompanyByUser(uidUser).map((company){
    if(company != null){
      return [company];
    }
    return [];
  });
  }else{
    return _local.getListCompanyByUser(uidUser);
  }


}

  @override
    Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil Usuario'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 15.0),
          child: IconButton(onPressed: _signOut,
            icon: Icon(Icons.logout),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
          ),
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _user.getUserData(userId),
        builder: (context, snapshot){
    if(snapshot.connectionState == ConnectionState.waiting){
    return Center(
    child: CircularProgressIndicator());
    }
    if (snapshot.hasError){
    return Center(
    child: Text('Error: ${snapshot.error}'));
    }
    if(!snapshot.hasData || snapshot.data == null){
    return Center(
    child: Text('No se encontraron datos del usuario'));
    }

    var user = snapshot.data!;

    //Obtenemos una lista de empresas
    return StreamBuilder<List<CompanyModel>>(
    stream: _getListEmpresasByUsu(userId,user.isCompany),
    builder: (context, companySnapshot){
    if(companySnapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator(),);
    }
    if(companySnapshot.hasError){
      return Center(child: Text('Error: ${companySnapshot.error}'),);
    }

    var companies = companySnapshot.data ?? [];

    return SingleChildScrollView(
    child: Padding(
    padding: EdgeInsets.all(screenWidth * 0.07),
    child: Column(
    children: [
    ListTile(
    title: Text(user.nameUser,
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
    subtitle: Text('Nombre y Apellidos'),
    ),
    Divider(),
    ListTile(
    title: Text(user.email,
    style: TextStyle(fontSize: 16),),
    subtitle: Text('Correo electrónico'),
    ),
    Divider(),
    ListTile(
    title: Text(user.phone,
    style: TextStyle(fontSize: 16),),
    subtitle: Text('Teléfono'),
    ),
    Divider(),
    if(user.isCompany) ...[
    for (var company in companies) ...[

    ListTile(
    title: Text(company.nameRest,
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
    subtitle: Text('Nombre del restaurante'),
    ),
    Divider(),
    ListTile(
    title: Text(company.province,
    style: TextStyle(fontSize: 16),),
    subtitle: Text('Provincia'),
    ),
    Divider(),
    ListTile(
    title: Text(company.address,
    style: TextStyle(fontSize: 16),),
    subtitle: Text('Dirección'),
    ),
    Divider(),
    ListTile(
    title: Text(company.city,
    style: TextStyle(fontSize: 16),),
    subtitle: Text('Ciudad'),
    ),
    Divider(),
    ListTile(
    title: Text(company.zipcode,
    style: TextStyle(fontSize: 16),),
    subtitle: Text('Código Postal'),
    ),
    Divider(),
    ],
    ],
    // botones
    SizedBox(height: 15),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    ElevatedButton.icon(
    onPressed: () => _editProfile(user, companies),
    icon: Icon(Icons.edit),
    label: Text('Editar Perfil'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey),
    ),

    ],
    ),
    ],
    ),
    ),
    );
    },
    );
    },
      ),
    );
  }
}
