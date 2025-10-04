import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_pass/Feature/Home/Screen/home.dart';
import 'package:sync_pass/Feature/Login/Screen/login_screen.dart';


/// Um widget que decide qual tela mostrar com base no estado de autenticação do usuário.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Ouve as mudanças no estado de autenticação do Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se o snapshot ainda está carregando, mostra um loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Se o usuário não está logado (não há dados no snapshot)
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Se o usuário está logado, mostra a HomeScreen
        return const HomeScreen();
      },
    );
  }
}
