
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Model/company_model.dart';
import 'package:flutter/cupertino.dart';

class RestaurantsService {
  final FirebaseFirestore firestore;

  RestaurantsService({required this.firestore});

  Future <List<CompanyModel>> getRestaurants() async{
    List<CompanyModel> restaurantList = [];
    
    try{
      QuerySnapshot querySnapshot = await firestore
          .collection('Empresas').get();

      restaurantList = querySnapshot.docs
      .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CompanyModel.fromFirestore(data,doc.id);
      }).toList();
    }catch (e){
      debugPrint('Error al obtener restaurantes: $e');
      throw Exception('No se pudieron obtener los restaurantes');
    }
    return restaurantList;
  }
  
  void loadRestaurants() async {
    try {
      List<CompanyModel> restaurants = await getRestaurants();

      if (restaurants.isEmpty) {
        debugPrint('No se encontraron restaurantes.');
        return;
      }
      for (var rest in restaurants) {
        debugPrint('Restaurante: ${rest.nameRest},Province: ${rest.province}\n,'
            ' Ciudad: ${rest.city},Dirección: ${rest
            .address}, Cod. Post.: ${rest.zipcode}');
      }
    } catch (e) {
      debugPrint('Error al cargar restaurantes: $e');
    }
  }

    Future<String> getRestaurantName(String restaurantUid) async {
      try {
        DocumentSnapshot doc = await firestore
            .collection('Empresas')
            .doc(restaurantUid).get();

        if (doc.exists) {
          return doc['name_rest'] ?? 'Restaurante Desconocido';
        } else {
          return 'Restaurante no Disponible';
        }
      } catch (e) {
        debugPrint('Error al obtener nombre rest: $e');
        return 'Error en nombre Restaurante';
      }
    }

}