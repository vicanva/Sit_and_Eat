
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Model/company_model.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:flutter/material.dart';

class CompanyService{
  final CollectionReference _companyCollec=
    FirebaseFirestore.instance.collection('Empresas');

  final UserService _userService = UserService();

  Future<void> addCompany(String uidUser,CompanyModel company) async{
    try{
      await _companyCollec.doc(uidUser).set(company.toMap()
      );
    }catch (e){
      throw Exception('Error al agregar empresa: $e');
    }
  }

  Future <CompanyModel?> getCompanyData(String compId) async {
    try{
      DocumentSnapshot doc = await _companyCollec.doc(compId).get();
      if (doc.exists && doc.data() != null){
        return CompanyModel.fromFirestore(doc.data() as Map<String,dynamic>, doc.id);
      }
      return null;
    } catch (e){
      debugPrint('Error al obtener los datos de la empresa: $e');
      return null;
    }
  }

  Stream<CompanyModel?> getCompanyByUser(String uidUser){
    return _companyCollec.doc(uidUser)
        .snapshots().map((snapshsot){
          if(snapshsot.exists){
            final data = snapshsot.data() as Map<String,dynamic>;
            return CompanyModel.fromFirestore(data,uidUser);
          }
          return null;
    });
  }

  Stream<List<CompanyModel>> getListCompanyByUser(String uidUser){
    return _companyCollec
        .where('uid_user', isEqualTo: uidUser)
        .snapshots().map((snapshot){
          return snapshot.docs.map((doc){
            final data = doc.data() as Map<String,dynamic>;
            return CompanyModel.fromFirestore(data, doc.id);
          }).toList();
    });
  }

  Future<void> updateCompany(String uidUser,CompanyModel company) async{
    try{
      await _companyCollec.doc(uidUser)
        .set(company.toMap(), SetOptions(merge: true)
        );
    }catch (e){
      throw Exception('Error al actualizar o crear empresa: $e');
    }
  }

  Future<void> deleteCompany(String uidUser) async{
    try{
      await _companyCollec.doc(uidUser).delete();

      final userCompanyDoc = await _companyCollec.doc(uidUser).get();

      if(!userCompanyDoc.exists) {
        await _userService.updateUserCompanyStatus(uidUser, false);
      }
    }catch (e){
      throw Exception('Error al eliminar empresa: $e');
    }
  }

}

