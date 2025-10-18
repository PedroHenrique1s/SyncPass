// Em: AddPass/Widgets/card_form.dart
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'custom_input_decoration.dart';

class CardForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController cardHolderNameController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryDateController;
  final TextEditingController cvvController;
  final MaskTextInputFormatter cardNumberFormatter;
  final MaskTextInputFormatter expiryDateFormatter;
  final MaskTextInputFormatter cvvFormatter;

  const CardForm({
    super.key,
    required this.titleController,
    required this.cardHolderNameController,
    required this.cardNumberController,
    required this.expiryDateController,
    required this.cvvController,
    required this.cardNumberFormatter,
    required this.expiryDateFormatter,
    required this.cvvFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: buildInputDecoration(
              labelText: 'Descrição (Ex: Nubank, Inter)',
              icon: Icons.label_outline),
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: cardHolderNameController,
          decoration: buildInputDecoration(
              labelText: 'Nome no Cartão', icon: Icons.person_outline),
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: cardNumberController,
          decoration: buildInputDecoration(
              labelText: 'Número do Cartão', icon: Icons.credit_card),
          keyboardType: TextInputType.number,
          inputFormatters: [cardNumberFormatter],
          validator: (v) => v == null || v.length < 19 ? 'Número inválido' : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: expiryDateController,
                decoration: buildInputDecoration(
                    labelText: 'Validade (MM/AA)',
                    icon: Icons.calendar_today_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [expiryDateFormatter],
                validator: (v) => v == null || v.length < 5 ? 'Data inválida' : null,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                controller: cvvController,
                decoration: buildInputDecoration(
                    labelText: 'CVV', icon: Icons.lock_outline),
                keyboardType: TextInputType.number,
                inputFormatters: [cvvFormatter],
                obscureText: true,
                validator: (v) => v == null || v.length < 3 ? 'CVV inválido' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}