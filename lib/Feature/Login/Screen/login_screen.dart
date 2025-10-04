import 'package:flutter/material.dart';
import 'package:sync_pass/Feature/Home/Screen/home.dart';
import 'package:sync_pass/Feature/Login/Screen/cpf_sreen.dart';
import 'package:sync_pass/Feature/Login/Services/auth_method.dart';

// ATENÇÃO: Verifique se este caminho para o seu serviço de autenticação está correto!

// ALTERADO: A classe foi convertida para StatefulWidget para gerir o estado de carregamento.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // NOVO: Variável de estado para controlar o indicador de carregamento.
  bool _isLoading = false;

Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (mounted) {
        if (userCredential != null && userCredential.user != null) {
          // SUCESSO NO LOGIN - NAVEGAÇÃO ACONTECE AQUI
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Este `false` remove todas as rotas anteriores
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login com Google cancelado.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: $e'),
            backgroundColor: Colors.red,
          ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                Image.asset(
                  'images/Logo.png',
                  height: 220,
                ),
                const SizedBox(height: 20),
                const Text(
                  'SyncPass',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Seu cofre digital\nsem complicações',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              // ALTERADO: Mostra o indicador de carregamento ou os botões.
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE0A800)),
                    )
                  : Column( 
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(_createRoute());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0A800),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Começar',
                            style: TextStyle(
                              color: Color(0xFF424242),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), // Espaçamento entre os botões

                        // 2. NOVO: Botão "Login with Google"
                        ElevatedButton.icon(
                          icon: Image.asset(
                            'images/google_logo.png', // Verifique se este asset está no seu projeto
                            height: 24.0,
                          ),
                          label: const Text(
                            'Login com Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 2,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            side: BorderSide(color: Colors.grey.shade300)
                          ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  // Função que cria a rota com animação
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const CpfScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}