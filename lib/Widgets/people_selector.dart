
import 'package:flutter/material.dart';

class PeopleSelector extends StatelessWidget{
  final int people;
  final Function(int) onChanged;

  const PeopleSelector({
    super.key, required this.people, required this.onChanged});


  @override
  Widget build(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
        value:  people,
        items: List.generate(40,
          (index) => DropdownMenuItem<int>(
            value: index +1,
            child: Text('${index +1}',textAlign: TextAlign.center,),
            ),
        ),
        onChanged: (newValue){
          if(newValue != null) {
            onChanged (newValue);
          }
    },
    ),
      ],
    );
  }



}

