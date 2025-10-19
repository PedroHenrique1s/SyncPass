import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sync_pass/Feature/Login/Screen/newlogin_screen.dart';
import 'package:sync_pass/Feature/Login/Services/auth_method.dart';

// Importe os novos widgets que criamos!
import 'package:sync_pass/Feature/Home/Widgets/home_user_info.dart';
import 'package:sync_pass/Feature/Home/Widgets/home_menu_grid.dart';
import 'package:sync_pass/Feature/Home/Widgets/home_security_carousel.dart';

const Color customYellow = Color(0xFFE0A800);

// Convertemos para StatelessWidget!
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Buscamos o usuário diretamente no método build
    final User? user = GoogleSignInService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'SyncPass',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: customYellow.withAlpha(102),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Sair',
            onPressed: () async {
              await GoogleSignInService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const NewLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HomeUserInfo(user: user),
            ),
            
            const SizedBox(height: 20),
            const HomeSecurityCarousel(),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const HomeMenuGrid(),
            ),

            const SizedBox(height: 30), // Espaço no final
          ],
        ),
      ),
    );
  }
}