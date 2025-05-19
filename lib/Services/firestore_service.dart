
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  FirestoreService._privateConstructor();

  static final FirestoreService instance = FirestoreService
      ._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // coleccio de base datos, id que pertany a dins la coleccio i mapa de la informacio
  Future<void> saveData(String collection, String uid,
      Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando datos en Firestore ($collection/$uid): $e');
      throw Exception('Error guardando en la Base de Datos.');
    }
  }

// coleccio de base datos i id que pertany a dins la coleccio
  Future<Map<String, dynamic>?> getData(String collection, String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection(collection)
          .doc(uid).get();
      if(!doc.exists) {
        return null;
      }

      final data = doc.data();
      if(data is Map<String,dynamic>){
        return data;
      }else{
        debugPrint('Error: Datos mal formateados en ($collection/$uid)');
        return null;
      }
    } catch (e) {
      debugPrint('Error obtenieno datos de Firebase ($collection/$uid): $e');
      return null;
    }
  }

  Future<void> deleteData(String collection, String uid) async{
    try{
      await _db.collection(collection)
          .doc(uid).delete();
      debugPrint('Documento eliminado: $collection/$uid');
    }catch (e){
      debugPrint('Error eliminando datos de Firestore ($collection/$uid): $e');
      throw Exception('Error eliminando datos en Firestore.');
    }
  }

  Future<String> getSenderName(String uid, String rol) async{
    final coleccion = rol == 'Cliente' ? 'Usuarios' : 'Empresas';
    final data = await getData(coleccion,uid);

    if(data == null){
      return 'Desconocido';
    }
    
    return rol == 'Cliente'
        ? data['name_user'] ?? 'Desconcido'
        : data['name_rest'] ?? 'Desconocido';
  }
  
  
}
