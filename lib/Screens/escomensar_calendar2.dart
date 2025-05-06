
import 'package:sit_and_eat/Model/reservas_model.dart';
import 'package:sit_and_eat/Screens/confirm_screen.dart';
import 'package:sit_and_eat/Services/reservation_service.dart';
import 'package:sit_and_eat/Widgets/DateCalendar.dart';
import 'package:sit_and_eat/Widgets/people_selector.dart';
import 'package:sit_and_eat/Widgets/restaurant_dropdown.dart';
import 'package:sit_and_eat/Widgets/time_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// La Correcta Clase en us
class EscomensarCalendar2 extends StatefulWidget {
  final String userId;

  const EscomensarCalendar2({
    super.key, required this.userId});

  @override
  EscomensarCalendarState createState() => EscomensarCalendarState();
}

class EscomensarCalendarState extends State<EscomensarCalendar2>{
  String? selectedRestaurant;
  String selectedTime = ReservasModel.times.first;
  int people = 1;
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  final ReservationService reservationService = ReservationService();

  @override
  void initState(){
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void dispose(){
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Mesa'),
      ),
      body: Padding(
        padding:EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Selecciona el Restaurante:',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              RestaurantDropdown(
                selectedRestaurant: selectedRestaurant,
                onChanged: (value) => setState(() =>
                selectedRestaurant = value),
              ),

              SizedBox(height: 12),
              DateCalendar(
                controller: _dateController,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 90)),
              ),

              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Comensales:', style: TextStyle(fontSize: 17),),
                        PeopleSelector(
                          people: people,
                          onChanged: (value) => setState(() =>
                          people = value),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Hora de reserva:', style: TextStyle(fontSize: 17),),
                      TimeDropdown(
                        selectedTime: selectedTime,
                        onChanged: (time) => setState(() =>
                        selectedTime = time!),
                      ),
                    ],
                  ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: _confirmReservation,
                  child: Text('Reservar'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  void _confirmReservation() async{
    if(selectedRestaurant == null){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecciona un restaurante'))
      );
      return;
    }

    if (_dateController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selecciona una fecha')),
      );
      return;
    }

    try{
      selectedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fecha inválida')),
      );
      return;
    }

    ReservasModel reserva= ReservasModel (
      createdAt: DateTime.now(),
      empresaUid: selectedRestaurant!,
      clienteUid: widget.userId,
      date: selectedDate,
      time: selectedTime,
      people: people,
      status: EstateReserve.processing,
      messages: [],
    );
    Map<String,dynamic> reservationData = reserva.toMap();

    try{
      String reservationId = await reservationService.saveReservationData(reservationData);

      if(reservationId.isNotEmpty && reservationId != 'Ya existe reserva a la misma hora y fecha'){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>
              ConfirmScreen(
                userId: widget.userId,
                reservationId: reservationId,
              ),
          ),
        );

      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La reserva ya existe.'))
        );
      }

    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se pudo reservar'))
      );
    }
  }

}

