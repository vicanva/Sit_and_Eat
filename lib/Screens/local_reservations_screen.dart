
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Model/reservas_model.dart';
import 'package:sit_and_eat/Services/reservation_service.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:sit_and_eat/Widgets/messagesWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocalReservationsScreen extends StatefulWidget{
  const LocalReservationsScreen({super.key});

  @override
  LocalReservationsScreenState createState() => LocalReservationsScreenState();
}

class LocalReservationsScreenState extends State<LocalReservationsScreen>{

  final ReservationService _reservationService = ReservationService();
  final UserService _userService = UserService();
  String restaurantUid = '';
  bool isLoading = true;
  bool isCompany = false;

  Future<void> loadRestaurantUid() async{
    try{
      String useruid = await _userService.getUserUid();
      isCompany = await _userService.isUserCompany(useruid);
      if(!isCompany){
        throw Exception('Acceso Denegado.');
      }

      restaurantUid = useruid;
      setState(() {
        isLoading = false;
      });

    }catch (e){
      debugPrint('Error cargando el restaurante: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  EstateReserve getReserveStatusFromString(String status){
    return EstateReserve.values.firstWhere(
        (e) => e.name == status,
      orElse: () => EstateReserve.processing,
    );
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
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


  Widget buildReservationCard(Map<String,dynamic> reservation){
    final screenWidth = MediaQuery.of(context).size.width;

    final String dateStr= reservation['date'] != null
        ? formatDate((reservation['date'] as Timestamp).toDate())
        : 'Fecha desconocida';

    final EstateReserve status = getReserveStatusFromString(reservation['status'] ?? 'processing');

    return FutureBuilder<String>(
        future: _userService.getUserName(reservation['cliente_uid'] ?? ''),
        builder: (context,snapshot){
          final clientName= snapshot.data ?? 'Cliente Desconocido';

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
                  Text(
                    'Cliente:',
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: status.name,
                    items: EstateReserve.values.map((e){
                      return DropdownMenuItem(
                          value: e.name,
                          child:Container(
                            padding: EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                            decoration: BoxDecoration(
                              color: getBackgroundColor(e),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          child: Text(e.displayName,
                          style: TextStyle(
                            color: _getStatusColor(e),
                            fontWeight: FontWeight.w600,
                          ),
                          ),
                          ),
                      );
                    }).toList(),
                    onChanged: (String? newStatus) async{
                      if(newStatus != null && newStatus != status.name){
                        await _reservationService.updateReservationStatus(reservation['id'], newStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Estado actualizado')),
                        );
                      }
                    },
                  )
                  ],
                  ),
                  Text(
                    clientName,
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                  ),
                  Text('Fecha: $dateStr',style: TextStyle(fontSize: 16),),
                  Text('Hora: ${reservation['time'] ?? 'Hora Desconocida'}',
                    style: TextStyle(fontSize: 16),),
                  Text('Personas: ${reservation['people'] ?? 'Cantidad Desconocida'}',
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
                            addMessage: _reservationService.addMessageToReservation,
                            sender: 'Empresa',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        );
  }

  @override
  void initState(){
    super.initState();
    loadRestaurantUid();
    _reservationService.deleteReservations();
    //solo para presentacion
    _reservationService.deletePresentation();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('RESERVAS EN TU RESTAURANTE'),
      ),
      body: isLoading
        ? Center(
        child: CircularProgressIndicator(),
      )
          : StreamBuilder<QuerySnapshot>(
          stream: _reservationService.streamReservationsByLocal(restaurantUid),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }else if (snapshot.hasError){
              return Center(
                child: Text('Error al cargar las reservas'),
              );
            }else if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
              return Center(
                child: Text('No hay reservas disponibles'),
              );
            }

            final reservations = snapshot.data!.docs.map((doc){
              final rawData= doc.data() as Map<String,dynamic>;
              final Map<String,dynamic> data = rawData.map((key,value)
              => MapEntry(key.toString(), value));
              data['id'] = doc.id;
              return data;
            }).toList();

            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context,index){
                final reservation= reservations[index];
                return buildReservationCard(reservation);
              },
            );
          },
          ),
    );
  }

}
