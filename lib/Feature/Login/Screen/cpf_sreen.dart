import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sync_pass/Feature/Home/validationCPF.dart';

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

  // 4. Variável para controlar a visibilidade da senha
  bool _isPasswordVisible = false;

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
                const SizedBox(height: 20),

                // --- 5. NOVO CAMPO E-MAIL ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    hintText: "seu@email.com",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, digite o e-mail";
                    }
                    // Validação simples para verificar se o e-mail tem um formato válido
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Digite um e-mail válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- 6. NOVO CAMPO SENHA ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Controla se o texto fica oculto
                  decoration: InputDecoration(
                    labelText: "Senha",
                    hintText: "********",
                    // Ícone para alternar a visibilidade da senha
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // Atualiza o estado para redesenhar a tela com a nova visibilidade
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, digite a senha";
                    }
                    if (value.length < 6) {
                      return "A senha deve ter no mínimo 6 caracteres";
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