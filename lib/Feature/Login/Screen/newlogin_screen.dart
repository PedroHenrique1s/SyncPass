// Arquivo: newlogin_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_pass/Feature/Home/Screen/home_screen.dart';
import 'package:sync_pass/Feature/Login/Screen/cpf_sreen.dart';

class NewLoginScreen extends StatefulWidget {
  const NewLoginScreen({super.key});

  @override
  State<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends State<NewLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  Future<void> _login() async {
    // 1. Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Ativa o indicador de carregamento
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Tenta fazer o login com o Firebase Auth DIRETAMENTE
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 4. Se o login for bem-sucedido, navega para a tela principal
      if (userCredential.user != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      // 5. Se o Firebase retornar um erro, mostra uma mensagem amigável
      String errorMessage = "Ocorreu um erro ao fazer login.";
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = "Nenhum utilizador encontrado com este e-mail.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "Senha incorreta. Por favor, tente novamente.";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 6. Garante que o indicador de carregamento pare, independentemente do resultado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final TextEditingController emailController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Digite seu e-mail para receber o link de redefinição.'),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: "seu@email.com"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () {
                // PASSO 3 ACONTECE AQUI
                _sendPasswordResetEmail(emailController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    if (email.isEmpty) return; // Não faz nada se o e-mail estiver vazio

    try {
      // Usa o método do Firebase para enviar o e-mail
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      // Mostra uma mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Link de redefinição enviado! Verifique seu e-mail."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Mostra uma mensagem de erro
      String errorMessage = "Ocorreu um erro.";
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        // Por segurança, não informamos se o e-mail existe ou não
        errorMessage = "Se este e-mail estiver cadastrado, um link será enviado.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: e.code == 'user-not-found' ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo
              crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os filhos na horizontal
              children: [
                const Spacer(flex: 2),

                // --- HEADER COM A LOGO ---
                Image.asset('images/Logo.png', height: 100),
                const SizedBox(height: 16),
                const Text(
                  "Bem-vindo de volta!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Faça login para continuar.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // --- CAMPOS DE E-MAIL E SENHA MODERNIZADOS ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) { /* Sua validação aqui */ return null; },
                ),
                const SizedBox(height: 20),
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
                    fillColor: Colors.black.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) { /* Sua validação aqui */ return null; },
                ),
                
                // --- LINK "ESQUECEU A SENHA?" ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showPasswordResetDialog,
                    child: Text(
                      "Esqueceu a senha?",
                      style: TextStyle(color: theme.colorScheme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- BOTÃO PRINCIPAL DE LOGIN ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),

                const Spacer(flex: 3),

                // --- LINK PARA CRIAR CONTA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Não tem uma conta?"),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CpfScreen())),
                      child: Text(
                        "Crie uma",
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}