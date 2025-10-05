import 'package:flutter/material.dart';
import 'package:sync_pass/Feature/Home/Screen/home_screen.dart';
import 'package:sync_pass/Feature/Login/Screen/newlogin_screen.dart';
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
      // NOVO: Container com um fundo gradiente suave
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFFAF9F6).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ALTERADO: Centralizando todo o conteúdo
              children: [
                const Spacer(flex: 2),

                // --- SEÇÃO PRINCIPAL COM LOGO E TEXTOS ---
                Image.asset('images/Logo.png', height: 180),
                const SizedBox(height: 24),
                const Text(
                  'SyncPass',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black26,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Seu cofre digital sem complicações',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),

                const Spacer(flex: 3),

                // --- SEÇÃO DE BOTÕES ---
                // A lógica de loading continua envolvendo os botões
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE0A800)),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Botão de E-mail
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).push(_createRoute()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0A800),
                              foregroundColor: const Color(0xFF424242),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Conectar com E-mail',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botão do Google
                          ElevatedButton.icon(
                            icon: Image.asset('images/google_logo.png', height: 22.0),
                            label: const Text('Conectar com Google', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 2,
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

  // Função que cria a rota com animação
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const NewLoginScreen(),
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