
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget{
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final bool isNumeric;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.isNumeric = false,
    this.maxLength,
});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
      maxLength: maxLength,
      decoration: InputDecoration(labelText: labelText),
    );
  }

}