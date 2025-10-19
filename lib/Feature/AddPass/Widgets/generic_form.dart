
import 'package:flutter/material.dart';
import 'custom_input_decoration.dart';
import 'password_form_field.dart';

class GenericForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController passwordController;

  const GenericForm({
    super.key,
    required this.titleController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: buildInputDecoration(
              labelText: 'Descrição', icon: Icons.label_outline),
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        PasswordFormField(
          controller: passwordController,
          labelText: 'Senha ou Chave',
          icon: Icons.key_outlined,
        ),
      ],
    );
  }
}