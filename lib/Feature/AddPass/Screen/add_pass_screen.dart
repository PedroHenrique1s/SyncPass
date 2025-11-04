// Em: AddPass/Screen/add_pass_screen.dart

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// NOVO: Importa o PasswordItem
import 'package:sync_pass/Feature/Passcode/Models/password_item.dart'; 
// ATUALIZADO: Importa o PasswordService de 'Passcode' que tem o 'updatePassword'
import 'package:sync_pass/Feature/Passcode/Services/savePass.dart'; 
// ATUALIZADO: Importa seu enum de um arquivo separado
import 'package:sync_pass/Feature/AddPass/Models/password_type.dart'; 
import 'package:sync_pass/Feature/AddPass/Widgets/card_form.dart';
import 'package:sync_pass/Feature/AddPass/Widgets/generic_form.dart';
import 'package:sync_pass/Feature/AddPass/Widgets/login_form.dart';

// REMOVIDO: O enum e o mapa foram movidos para 'password_type.dart'

const Color customYellow = Color(0xFFE0A800);

class AddPassScreen extends StatefulWidget {
  // NOVO: Parâmetro opcional para o modo de Edição
  final PasswordItem? itemToEdit;

  // ATUALIZADO: Construtor aceita o itemToEdit
  const AddPassScreen({super.key, this.itemToEdit});

  @override
  State<AddPassScreen> createState() => _AddPassScreenState();
}

class _AddPassScreenState extends State<AddPassScreen> {
  // --- Controllers e Keys ---
  final _formKey = GlobalKey<FormState>();
  // (Controladores existentes estão corretos)
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // --- Formatters ---
  // (Formatters existentes estão corretos)
  final _expiryDateFormatter = MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r'[0-9]')});
  final _cardNumberFormatter = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
  final _cvvFormatter = MaskTextInputFormatter(mask: '###', filter: {"#": RegExp(r'[0-9]')});

  // --- State ---
  PasswordType _selectedType = PasswordType.login;
  bool _isLoading = false;

  // NOVO: Getter para verificar o modo
  bool get isEditing => widget.itemToEdit != null;

  // --- Service ---
  final PasswordService _passwordService = PasswordService();

  @override
  void initState() {
    super.initState();
    // NOVO: Se estiver editando, pré-preenche o formulário
    if (isEditing) {
      _prefillForm();
    }
  }

  // NOVO: Função para pré-preencher os campos
  void _prefillForm() {
    // Pega os dados brutos do item
    final data = widget.itemToEdit!.rawData; 
    // Define o tipo e impede que o dropdown seja alterado
    final typeString = data['type'] as String? ?? 'login';
    
    // Define o tipo e os controladores
    _selectedType = PasswordType.values.byName(typeString);
    _titleController.text = data['title'] ?? '';

    switch (_selectedType) {
      case PasswordType.login:
        _usernameController.text = data['username'] ?? '';
        _passwordController.text = data['password'] ?? '';
        break;
      case PasswordType.card:
        _cardHolderNameController.text = data['cardHolderName'] ?? '';
        // O Formatter aplicará a máscara ao texto salvo
        _cardNumberController.text = data['cardNumber'] ?? ''; 
        _expiryDateController.text = data['expiryDate'] ?? '';
        _cvvController.text = data['cvv'] ?? '';
        break;
      case PasswordType.generic:
        _passwordController.text = data['password'] ?? '';
        break;
    }
  }

  // ATUALIZADO: Função _savePassword agora é _saveOrUpdate
  Future<void> _saveOrUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    // ATUALIZADO: Constrói o mapa de dados com base no tipo
    // para enviar ao serviço.
    final Map<String, dynamic> dataToSave = {
      'title': _titleController.text.trim(),
    };

    // Adiciona apenas os campos relevantes para o tipo selecionado
    switch (_selectedType) {
      case PasswordType.login:
        dataToSave.addAll({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        });
        break;
      case PasswordType.card:
        dataToSave.addAll({
          'cardHolderName': _cardHolderNameController.text.trim(),
          'cardNumber': _cardNumberFormatter.getMaskedText(),
          'expiryDate': _expiryDateFormatter.getMaskedText(),
          'cvv': _cvvController.text,
        });
        break;
      case PasswordType.generic:
        dataToSave.addAll({
          'password': _passwordController.text,
        });
        break;
    }

    try {
      if (isEditing) {
        // --- MODO EDIÇÃO ---
        await _passwordService.updatePassword(
          widget.itemToEdit!.documentId, // Passa o ID
          dataToSave, // Passa o mapa de dados atualizados
        );
      } else {
        // --- MODO ADIÇÃO ---
        // (Usa a lógica que você já tinha)
        await _passwordService.savePasswordData(
          type: _selectedType,
          rawData: dataToSave, // Passa o mapa de dados
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Mensagem dinâmica
            content: Text('Item ${isEditing ? 'atualizado' : 'salvo'} com sucesso!'),
            backgroundColor: Colors.green
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ${isEditing ? 'atualizar' : 'salvar'}: ${e.toString()}'), backgroundColor: Colors.red),
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

  // ATUALIZADO: Não faz nada se estiver em modo de edição
  void _onTypeChanged(PasswordType? newValue) {
    if (newValue == null || isEditing) return; // Não permite trocar o tipo
    setState(() {
      _selectedType = newValue;
      // ... (seu código de limpar os campos está correto)
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
        // ATUALIZADO: Título dinâmico
        title: Text(
          isEditing ? 'Editar Item' : 'Adicionar Novo Item', 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)
        ),
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
              // ATUALIZADO: 'value' é usado para controlar o estado
              value: _selectedType, 
              decoration: InputDecoration(
                labelText: 'Tipo de Item',
                filled: true,
                // ATUALIZADO: Cor de fundo muda se estiver editando
                fillColor: isEditing ? Colors.grey[200] : Colors.white, 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: passwordTypeLabels.entries.map((entry) {
                return DropdownMenuItem(value: entry.key, child: Text(entry.value));
              }).toList(),
              // ATUALIZADO: Desabilita a troca de tipo no modo de edição
              onChanged: isEditing ? null : _onTypeChanged,
            ),
            const SizedBox(height: 20),

            // O formulário principal
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDynamicFormFields(),
                  const SizedBox(height: 40),
                  
                  // Botão Salvar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      // ATUALIZADO: Chama a nova função _saveOrUpdate
                      onPressed: _isLoading ? null : _saveOrUpdate, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          // ATUALIZADO: Texto do botão dinâmico
                          : Text(
                              isEditing ? 'Salvar Alterações' : 'Salvar Item',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
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

  // ATUALIZADO: Nenhuma mudança necessária aqui, 
  // pois ele já usa os controllers que foram pré-preenchidos.
  Widget _buildDynamicFormFields() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_selectedType),
        child: switch (_selectedType) {
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