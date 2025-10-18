// Em: AddPass/Widgets/password_form_field.dart
import 'package:flutter/material.dart';
import 'custom_input_decoration.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon; // <-- 1. ADICIONE ESTA LINHA

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon, // <-- 2. E ADICIONE ESTA LINHA
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: buildInputDecoration(
        labelText: widget.labelText,
        icon: widget.icon, // <-- 3. Agora 'widget.icon' vai funcionar
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}