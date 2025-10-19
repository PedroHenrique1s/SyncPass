import 'package:flutter/material.dart';
import 'custom_input_decoration.dart'; 
import 'password_form_field.dart'; 

class LoginForm extends StatelessWidget {

  final TextEditingController titleController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.titleController,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: buildInputDecoration(
              labelText: 'Nome do Site/App', icon: Icons.public),
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: usernameController,
          decoration: buildInputDecoration(
              labelText: 'Usuário ou E-mail', icon: Icons.person_outline),
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        
        PasswordFormField(
          controller: passwordController,
          labelText: 'Senha',
          icon: Icons.lock_outline,
        ),
      ],
    );
  }
}