
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Screens/home_screen.dart';
import 'package:sit_and_eat/Services/restaurants_service.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmScreen extends StatelessWidget {
  final String userId;
  final String reservationId;
  final RestaurantsService restService = RestaurantsService(firestore: FirebaseFirestore.instance);

  ConfirmScreen({super.key,
    required this.userId,
    required this.reservationId});

  Future<Map<String, dynamic>?> reservationDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Reservas').doc(reservationId).get();

      if (doc.exists && doc.data() != null) {
        return Map<String, dynamic>.from(doc.data() as Map);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener los detalles de la reserva: $e');
      return null;
    }
  }

  Future<Map<String, String>> getUserDetails(String userId) async {
    try {
      final userName = await UserService().getUserName(userId);
      final userPhone = await UserService().getUserPhone(userId);

      return {
        'name_user': userName.isNotEmpty ? userName : 'Usuario Desconocido',
        'phone': userPhone.isNotEmpty ? userPhone : 'Movil Desconocido',
      };
    } catch (e) {
      debugPrint('Error al obtener usuario: $e');
      return {
        'name_user': 'Usuario desconocido',
        'phone': 'Movil desconocido',
      };
    }
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text('Confirmación de Reserva'),
        ),
        // dades reserva
        body: FutureBuilder<Map<String, dynamic>?>(
            future: reservationDetails(),
            builder: (context, resSnapshot) {
              if (resSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (resSnapshot.hasError) {
                return const Center(
                  child: Text('Error al cargar los detalles de la reserva'),
                );
              } else if (!resSnapshot.hasData || resSnapshot.data == null) {
                return const Center(
                  child: Text('No se encontró la reserva'),
                );
              } else {
                final reservation = resSnapshot.data!;

                // dades usuari
                return FutureBuilder<Map<String, String>>(
                    future: getUserDetails(userId),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (userSnapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Error al cargar los detalles de la reserva'),
                        );
                      } else
                      if (!userSnapshot.hasData || userSnapshot.data == null) {
                        return const Center(
                          child: Text('No se encontró la reserva'),
                        );
                      } else {
                        final userDetails = userSnapshot.data!;

                        // dades empresa
                        String restaurantUid = reservation['empresa_uid']
                            ?? '';
                        return FutureBuilder<String>(
                            future: restService.getRestaurantName(restaurantUid),
                            builder: (context, restaurantSnapshot) {
                              if (restaurantSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (restaurantSnapshot.hasError) {
                                return const Center(
                                  child: Text(
                                      'Error al cargar los detalles de la reserva'),
                                );
                              } else if (!restaurantSnapshot.hasData ||
                                  restaurantSnapshot.data == null) {
                                return const Center(
                                  child: Text(
                                      'No se encontró nombre del restaurante'),
                                );
                              } else {
                                final restaurantName = restaurantSnapshot.data!;

                                // cambiar formato fecha
                                DateTime date = reservation['date'] is Timestamp
                                    ? (reservation['date'] as Timestamp)
                                    .toDate() : DateTime.now();
                                String formattedDate = formatDate(date);

                                // dades reserva
                                return Center(
                                  child: Container(
                                    width: screenWidth * 0.9,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Detalles de la Reserva:',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 15),
                                      Text('Restaurante:',
                                        style: TextStyle(
                                          fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration
                                                .underline),),
                                      Text(restaurantName,
                                        style: TextStyle(
                                          fontSize: 20,
                                            fontWeight: FontWeight.bold),),
                                      SizedBox(height: 8),
                                      Text('Fecha: $formattedDate',
                                      style: TextStyle(fontSize: 18),),
                                      Text('Hora: ${reservation['time'] ??
                                          'Hora desconocida'}',
                                      style: TextStyle(fontSize: 18),),
                                      const SizedBox(height: 10),
                                      Text('Nombre de reserva:',
                                        style: TextStyle(
                                          fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration
                                                .underline),),
                                      Text(userDetails['name_user'] ??
                                          ' Nombre Desconocido',
                                        style: TextStyle(
                                          fontSize: 18,
                                            fontWeight: FontWeight.bold),),
                                      SizedBox(height: 8),
                                      Text(
                                          'Movil de contacto: ${userDetails['phone']}',
                                      style: TextStyle(fontSize: 18),),
                                      const SizedBox(height: 14),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber),
                                        child: Text('Continuar'),
                                      ),
                                    ],
                                  ),
                                  ),
                                );
                              }
                            }
                        );
                      }
                    }
                );
              }
            }
        )
    );
  }
}
