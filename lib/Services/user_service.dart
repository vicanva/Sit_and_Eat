
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future <UserModel?> getUserData(String userId) async {
    try{
      DocumentSnapshot doc = await _db.collection('Usuarios').doc(userId).get();
      if (doc.exists && doc.data() != null){
        return UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e){
      debugPrint('Error al obtener los datos del usuario: $e');
      return null;
    }
  }

// Guardar dades del usuari
  static Future<void> saveUserData(String userId, UserModel user) async{
    try{
      await _db.collection('Usuarios')
          .doc(userId)
          .set(user.toMap(), SetOptions(merge: true));
    }catch (e){
      debugPrint('Error al guardar los datos del usuario: $e');
      rethrow;
    }
  }

  Future<String> getUserUid() async{
    final user = FirebaseAuth.instance.currentUser;
    if( user == null){
      throw Exception('El usuario no esta autenticado');
    }
    return user.uid;
  }

  Future<String> getUserName(String userId) async{
    try{
      final DocumentSnapshot userDoc =
      await _db.collection('Usuarios').doc(userId).get();
      return userDoc['name_user'] ?? 'Usuario desconocido';
    }catch (e){
      print('Error al obtener el nombre del usuario: $e');
      return 'Usuario error';
    }
  }

  Future<String> getUserPhone(String userId) async{
    try{
      final DocumentSnapshot userDoc =
      await _db.collection('Usuarios').doc(userId).get();
      return userDoc['phone'] ?? 'Movil desconocido';
    }catch (e){
      print('Error al obtener el movil del usuario: $e');
      return 'Movil error';
    }
  }

  Future<bool> isUserCompany (String userId) async{
    try{
      final DocumentSnapshot userDoc = await
          _db.collection('Usuarios')
              .doc(userId).get();

      if(userDoc.exists && userDoc.data() != null){
        return (userDoc['is_company'] ?? false) as bool;
      }
      return false;
    }catch (e){
      debugPrint('Error verificando si el usuario es empresa: $e');
      return false;
    }
  }

  Future<void> updateUserCompanyStatus(String userId,bool isCompany) async{
    try{
      await _db.collection('Usuarios')
          .doc(userId)
          .update({'is_company':isCompany});
    }catch (e){
      debugPrint('Error al actualizar isCompany: $e');
    }
  }


}