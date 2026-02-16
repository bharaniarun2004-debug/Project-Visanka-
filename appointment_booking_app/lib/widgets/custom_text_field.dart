import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: Theme.of(context).primaryColor),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
