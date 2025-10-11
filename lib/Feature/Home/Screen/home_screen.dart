// home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_pass/Feature/Login/Screen/login_screen.dart';
import 'package:sync_pass/Feature/Login/Services/auth_method.dart';
import 'package:sync_pass/Feature/Generator/Screen/generator_screen.dart';
import 'package:sync_pass/Feature/AddPass/Screen/add_pass_screen.dart';
import 'package:sync_pass/Feature/Passcode/Screen/passcode_screen.dart';

// Definindo a nova cor amarela
const Color customYellow = Color(0xFFE0A800);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = GoogleSignInService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SyncPass',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sair',
            onPressed: () async {
              await GoogleSignInService.signOut();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seção de Boas-Vindas e Avatar
              _buildUserInfoSection(user),
              const SizedBox(height: 30),

              // Seção de Menu Central (Grid de Botões)
              _buildMenuGrid(context),
              const SizedBox(height: 30),

              // Seção de Informações Adicionais (Cards)
              _buildRecentPasswordsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares para o Novo Layout ---

  Widget _buildUserInfoSection(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child: user?.photoURL == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
        ),
        const SizedBox(height: 10),
        Text(
          'Bem-vindo(a), ${user?.displayName ?? 'Usuário'}!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user?.email ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    // Lista de opções do menu
    // Dentro de _buildMenuGrid

final List<Map<String, dynamic>> menuItems = [
  {'title': 'Minhas Senhas', 'icon': Icons.lock, 'onTap': () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PasscodeScreen()),
    );
  }},
  {'title': 'Adicionar Nova', 'icon': Icons.add_circle, 'onTap': () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddPassScreen()),
    );
  }},
  {'title': 'Gerar Senha', 'icon': Icons.vpn_key, 'onTap': () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GeneratorScreen()),
    );
  }},
  {'title': 'Configurações', 'icon': Icons.settings, 'onTap': () { /* ... */ }},
];

    return GridView.builder(
      shrinkWrap: true, // Para o GridView se adaptar ao espaço da Column
      physics: const NeverScrollableScrollPhysics(), // Desativa o scroll do GridView
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        childAspectRatio: 1.5, // Proporção para deixar os itens retangulares
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItemCard(
          title: item['title'],
          icon: item['icon'],
          onTap: item['onTap'],
        );
      },
    );
  }

  Widget _buildMenuItemCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: customYellow), // Cor alterada aqui!
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPasswordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Senhas Recentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        // Exemplo de um item de senha
        _buildPasswordItem(
          title: 'Google',
          subtitle: 'Último acesso em 10/10/2025',
          icon: Icons.lock_open,
        ),
        const Divider(),
        _buildPasswordItem(
          title: 'GitHub',
          subtitle: 'Último acesso em 09/10/2025',
          icon: Icons.lock_open,
        ),
      ],
    );
  }

  Widget _buildPasswordItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: customYellow), // Cor alterada aqui!
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Ação para visualizar a senha
      },
    );
  }
}