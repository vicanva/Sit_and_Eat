import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Services/reservation_service.dart';
import 'package:sit_and_eat/Widgets/messagesWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/reservas_model.dart';


class ReservedScreens extends StatefulWidget {
  const ReservedScreens({super.key});

  @override
  ReservedScreensState createState() => ReservedScreensState();
}

class ReservedScreensState  extends State<ReservedScreens> {

  final ReservationService service = ReservationService();

  Future<List<Map<String, dynamic>>> loadReservUser() async {
    String userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userUid.isEmpty) {
      throw Exception('El usuario no está autenticado');
    }

    try {
      List<Map<String, dynamic>> reservations = await service
          .getReservationsByClient(userUid);
      print('Reservas: $reservations');
      return reservations;
    } catch (e) {
      print('Error al cargar reservas: $e');
      rethrow;
    }
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }
  
  EstateReserve getReserveStatusFromString(String status){
    return EstateReserve.values.firstWhere(
          (e) => e.name == status,
      orElse: () => EstateReserve.processing,
    );
  }
  
  Color _getStatusColor(EstateReserve status){
    switch(status){
      case EstateReserve.processing:
        return Colors.orange;
      case EstateReserve.canceled:
        return Colors.red;
      case EstateReserve.approved:
        return Colors.green;
      case EstateReserve.pending:
        return Colors.orange;
      }
  }
  Color getBackgroundColor(EstateReserve status){
    switch(status){
      case EstateReserve.processing:
        return Colors.orange.shade100;
      case EstateReserve.canceled:
        return Colors.red.shade100;
      case EstateReserve.approved:
        return Colors.green.shade100;
      case EstateReserve.pending:
        return Colors.orange.shade100;
      }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('MIS RESERVAS REALIZADAS'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future:loadReservUser(),
        builder: (context, snapshot){
          if(snapshot.connectionState== ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text('Error al cargar las reservas'),);
          }else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center( child: Text('No tienes reservas realizadas'),);
          }else {
            final reservations = snapshot.data!;

            return ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  // cambiar formato data
                  final String restaurName= reservation['name_rest'] ?? 'Restaurante Desconocido';
                  final String dateStr= reservation['date'] != null
                    ? formatDate((reservation['date'] as Timestamp).toDate())
                    : 'Fecha desconocida';
                  final String time = reservation['time'] ?? 'Hora desconocida';
                  final String people= reservation['people']?.toString() ?? 'Desconocido';
                  final EstateReserve status = getReserveStatusFromString(reservation['status'] ?? 'processing');

                  return Card(
                    margin: EdgeInsets.all(screenWidth * 0.03),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text('Restaurante:',
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                          ),

                            Container( padding: EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                              decoration: BoxDecoration(
                                color: getBackgroundColor(status),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(status.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                          ),
                          ),
                          ],
                          ),
                          Text(restaurName,
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Text('Fecha: $dateStr',
                            style: TextStyle(fontSize: 16),),
                          Text('Hora: $time',
                            style: TextStyle(fontSize: 16),),
                          Text('Personas: $people',
                            style: TextStyle(fontSize: 16),),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.chat_outlined),
                              label: Text("Abrir Chat"),
                              onPressed: (){
                                MessagesWidget.showTheDialog(
                                  context,
                                  reservationId: reservation['id'],
                                  addMessage: service.addMessageToReservation,
                                  sender: 'Cliente',
                                );
                              },
                            ),
                          ),
                          ]
                      ),
                    ),
                  );
                }
            );
          }
        },
      ),
    );
  }
}

