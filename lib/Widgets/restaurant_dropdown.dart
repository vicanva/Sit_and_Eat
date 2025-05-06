
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantDropdown extends StatelessWidget{
  final String? selectedRestaurant;
  final Function(String?) onChanged;

  const RestaurantDropdown({
    super.key, this.selectedRestaurant, required this.onChanged});


  @override
  Widget build(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Empresas').snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<DropdownMenuItem<String>> items = snapshot.data!.docs.map((doc){
            return DropdownMenuItem(
              value: doc.id,
              child: Text(doc['name_rest']),
            );
          }).toList();

        return DropdownButton<String>(
          value: selectedRestaurant,
          items: items,
          onChanged: onChanged,
          hint: Text('Selecciona un restaurante'),
        );
        }
        );
  }

}

