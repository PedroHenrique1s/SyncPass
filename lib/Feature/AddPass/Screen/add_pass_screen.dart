// Em: AddPass/Screen/add_pass_screen.dart

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sync_pass/Feature/AddPass/Services/savePass.dart';
import 'package:sync_pass/Feature/AddPass/Widgets/card_form.dart';
import 'package:sync_pass/Feature/AddPass/Widgets/generic_form.dart';
import 'package:sync_pass/Feature/AddPass/Widgets/login_form.dart';

// Mova isso para um arquivo 'models/password_type.dart'
// para poder importar nos widgets também
enum PasswordType { login, card, generic }

const Map<PasswordType, String> passwordTypeLabels = {
  PasswordType.login: 'Login de Site/App',
  PasswordType.card: 'Cartão de Crédito',
  PasswordType.generic: 'Senha Genérica / Nota',
};
// Fim do arquivo do model

const Color customYellow = Color(0xFFE0A800);


class AddPassScreen extends StatefulWidget {
  const AddPassScreen({super.key});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _AddPassScreenState extends State<AddPassScreen> {
  // --- Controllers e Keys ---
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // --- Formatters ---
  final _expiryDateFormatter = MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r'[0-9]')});
  final _cardNumberFormatter = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
  final _cvvFormatter = MaskTextInputFormatter(mask: '###', filter: {"#": RegExp(r'[0-9]')});

  // --- State ---
  PasswordType _selectedType = PasswordType.login;
  bool _isLoading = false;
  // A variável _isPasswordVisible foi removida daqui!

  // --- Service ---
  final PasswordService _passwordService = PasswordService();

  // A função _savePassword permanece idêntica
  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    final Map<String, dynamic> allData = {
      'title': _titleController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'cardHolderName': _cardHolderNameController.text.trim(),
      'cardNumber': _cardNumberFormatter.getMaskedText(),
      'expiryDate': _expiryDateFormatter.getMaskedText(),
      'cvv': _cvvController.text,
    };

    try {
      await _passwordService.savePasswordData(
        type: _selectedType,
        rawData: allData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salvo com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Limpa os campos ao trocar o tipo
  void _onTypeChanged(PasswordType? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedType = newValue;
      _titleController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _cardHolderNameController.clear();
      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvvController.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Adicionar Novo Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        // MUDANÇA: Cor limpa, igual ao fundo (como você preferiu na outra tela)
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Dropdown de seleção de tipo
            DropdownButtonFormField<PasswordType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de Item',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: passwordTypeLabels.entries.map((entry) {
                return DropdownMenuItem(value: entry.key, child: Text(entry.value));
              }).toList(),
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 20),

            // O formulário principal
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // O widget dinâmico agora chama os widgets externos
                  _buildDynamicFormFields(),
                  const SizedBox(height: 40),
                  
                  // Botão Salvar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          : const Text('Salvar Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Este widget agora apenas decide QUAL widget externo construir.
  Widget _buildDynamicFormFields() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        // A Key é essencial para o AnimatedSwitcher saber que o widget mudou
        key: ValueKey(_selectedType),
        child: switch (_selectedType) {
          // Chama os novos widgets, passando os controllers
          PasswordType.login => LoginForm(
              titleController: _titleController,
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
          PasswordType.card => CardForm(
              titleController: _titleController,
              cardHolderNameController: _cardHolderNameController,
              cardNumberController: _cardNumberController,
              expiryDateController: _expiryDateController,
              cvvController: _cvvController,
              cardNumberFormatter: _cardNumberFormatter,
              expiryDateFormatter: _expiryDateFormatter,
              cvvFormatter: _cvvFormatter,
            ),
          PasswordType.generic => GenericForm(
              titleController: _titleController,
              passwordController: _passwordController,
            ),
        },
      ),
    );
  }
}