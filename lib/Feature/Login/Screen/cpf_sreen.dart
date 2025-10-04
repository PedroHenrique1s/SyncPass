import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sync_pass/Core/validationCPF.dart';

// 1. Classe renomeada de ValidationPage para CpfScreen
class CpfScreen extends StatefulWidget {
  const CpfScreen({super.key});

  @override
  // 2. Estado correspondente também foi renomeado
  State<CpfScreen> createState() => _CpfScreenState();
}

class _CpfScreenState extends State<CpfScreen> {
  // Chave para o nosso formulário, para gerir a validação
  final _formKey = GlobalKey<FormState>();

  // 3. Controladores para cada campo de texto
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Máscara para o campo de CPF
  final cpfFormatter = MaskTextInputFormatter(
    mask: "###.###.###-##",
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Função chamada ao pressionar o botão de avançar
  void _submitForm() {
    // A validação verifica todos os TextFormField dentro do Form
    if (_formKey.currentState!.validate()) {
      // Se todos os campos forem válidos, capturamos os dados
      String cpf = _cpfController.text;
      String email = _emailController.text;
      String password = _passwordController.text; // Lembre-se de nunca expor a senha assim em produção

      // Mensagem de sucesso (exemplo)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sucesso! CPF: $cpf, E-mail: $email, Senha: $password")),
      );
      // Aqui você pode adicionar a lógica para navegar para a próxima tela
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão voltar
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
                
                // Título e subtítulo atualizados
                const Text(
                  "Crie sua conta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Preencha os seus dados para continuar.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                // --- CAMPO CPF ---
                TextFormField(
                  controller: _cpfController,
                  inputFormatters: [cpfFormatter],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "CPF",
                    hintText: "000.000.000-00",
                    // (O resto da decoração foi mantido)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, digite o CPF";
                    }
                    if (value.length < 14) {
                      return "CPF deve ter 11 dígitos";
                    }
                    if (!isValidCPF(value)) { // Supondo que você tenha a função isValidCPF
                      return "CPF inválido";
                    }
                    return null;
                  },
                ),

                const Spacer(), // Empurra o botão para o final
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: _submitForm, // Chama a função de submissão do formulário
                    backgroundColor: const Color(0xFFE0A800),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}