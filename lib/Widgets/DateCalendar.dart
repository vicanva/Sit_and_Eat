
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// La Correcta Clase en us
class DateCalendar extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateCalendar({
    super.key,
    required this.controller,
    this.labelText = 'Fecha de la Reserva',
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  DateCalendarWidgetState createState() => DateCalendarWidgetState();
}

class DateCalendarWidgetState extends State<DateCalendar> {

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  Future<void> _selectedDate() async {
    final DateTime now = DateTime.now();
    final DateTime actualInitialDate = widget.initialDate ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: actualInitialDate,
      firstDate: widget.firstDate ?? now,
      lastDate: widget.lastDate ?? now.add(Duration(days: 90)),
      locale: const Locale('es','ES'),
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text = formatDate(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child:  TextField(
          controller: widget.controller,
          readOnly: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
            labelText: widget.labelText,
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: _selectedDate,),
          ),
        ),
      ),
    );
  }
}
