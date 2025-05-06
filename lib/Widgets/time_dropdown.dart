
import 'package:sit_and_eat/Model/reservas_model.dart';
import 'package:flutter/material.dart';

class TimeDropdown extends StatelessWidget{
  final String selectedTime;
  final Function(String?) onChanged;

  const TimeDropdown({
    super.key, required this.selectedTime, required this.onChanged});

  @override
  Widget build(BuildContext context){
    return DropdownButton(
        value: selectedTime,
        items: ReservasModel.times.map((time){
          return DropdownMenuItem<String>(
            value: time,
            child: Text(time),
          );
        }).toList(),
        onChanged: onChanged,
    );
  }

}

