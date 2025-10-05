import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sync_pass/Core/validationCPF.dart';
import 'package:sync_pass/Feature/Home/Screen/home_screen.dart';

// 1. Classe renomeada de ValidationPage para CpfScreen
class CpfScreen extends StatefulWidget {
  const CpfScreen({super.key});

  @override
  // 2. Estado correspondente também foi renomeado
  State<CpfScreen> createState() => _CpfScreenState();
}

class _CpfScreenState extends State<CpfScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final cpfFormatter = MaskTextInputFormatter(
    mask: "###.###.###-##",
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Função para criar a conta e salvar os dados
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Se o formulário não for válido, não faz nada
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Pega os dados dos controladores
      String email = _emailController.text.trim();
      String password = _passwordController.text;
      // Remove a formatação do CPF para salvar apenas os números
      String cpf = _cpfController.text.replaceAll(RegExp(r'[.-]'), '');

      // PASSO 1: Verificar se o CPF já existe no Firestore
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        // Se encontrou algum documento, o CPF já está em uso
        throw FirebaseAuthException(code: 'cpf-already-in-use');
      }

      // PASSO 2: Criar o utilizador no Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // PASSO 3: Salvar os dados adicionais no Firestore usando o UID do Auth
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'cpf': cpf, // Salva o CPF limpo
          'createdAt': FieldValue.serverTimestamp(),
          // Adicione outros campos que desejar, como 'nome'
        });

        // PASSO 4: Navegar para a tela principal após o sucesso
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ocorreu um erro ao criar a conta.";
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este e-mail já está em uso por outra conta.';
      } else if (e.code == 'cpf-already-in-use') {
        errorMessage = 'Este CPF já está cadastrado.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Pega o tema para usar as cores

    return Scaffold(
      // Usamos um SingleChildScrollView para evitar que o teclado
      // quebre o layout em telas menores.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER COM LOGO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(26), // Um amarelo bem claro
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão voltar com um fundo para melhor visualização
                CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(128),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 30),

                // --- ALTERAÇÃO AQUI ---
                // Usamos uma Row para alinhar os itens horizontalmente
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Alinha verticalmente
                  children: [
                    Image.asset('images/Logo.png', height: 60), // Sua logo
                    const SizedBox(width: 16), // Espaçamento entre a logo e o texto
                    // Supondo que 'SyncPass.png' é uma imagem com o texto "SyncPass"
                    Image.asset('images/SyncPass.png', height: 40), 
                  ],
                ),
                // --- FIM DA ALTERAÇÃO ---

                const SizedBox(height: 20),
                const Text(
                  "Crie sua conta",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Preencha os seus dados para continuar.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            ),

            // --- FORMULÁRIO ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- CAMPO CPF MODERNIZADO ---
                    TextFormField(
                      controller: _cpfController,
                      inputFormatters: [cpfFormatter],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "CPF",
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: Colors.black.withAlpha(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Por favor, digite o CPF";
                        if (value.length < 14) return "CPF deve ter 11 dígitos";
                        if (!isValidCPF(value)) return "CPF inválido";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO E-MAIL MODERNIZADO ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "E-mail",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.black.withAlpha(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Por favor, digite o e-mail";
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Digite um e-mail válido";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO SENHA MODERNIZADO ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        filled: true,
                        fillColor: Colors.black.withAlpha(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Por favor, digite a senha";
                        if (value.length < 6) return "A senha deve ter no mínimo 6 caracteres";
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // --- BOTÃO DE AÇÃO PRINCIPAL ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Criar Conta',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}