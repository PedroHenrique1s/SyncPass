import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_pass/Feature/Login/Screen/login_screen.dart'; // Importe a tela de login
import 'package:sync_pass/Feature/Login/Services/auth_method.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = GoogleSignInService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        title: const Text('Página Inicial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await GoogleSignInService.signOut();

              // SUGESTÃO 1: Navega imediatamente para a tela de login
              // para um feedback mais rápido ao utilizador.
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SUGESTÃO 2: Adicionado um 'child' ao CircleAvatar como fallback
            // caso a imagem de fundo (backgroundImage) não carregue.
            CircleAvatar(
              radius: 50,
              // Tenta carregar a imagem da rede
              backgroundImage: user?.photoURL != null 
                  ? NetworkImage(user!.photoURL!) 
                  : null,
              // Se não houver URL ou a imagem falhar, mostra um ícone padrão
              child: user?.photoURL == null 
                  ? const Icon(Icons.person, size: 50) 
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Bem-vindo(a), ${user?.displayName ?? 'Usuário'}!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'Nenhum e-mail fornecido',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}