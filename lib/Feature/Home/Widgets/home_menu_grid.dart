import 'package:flutter/material.dart';
import 'package:sync_pass/Feature/Folder/Screens/folder_Screen.dart';

import 'package:sync_pass/Feature/Generator/Screen/generator_screen.dart';
import 'package:sync_pass/Feature/AddPass/Screen/add_pass_screen.dart';
import 'package:sync_pass/Feature/Passcode/Screen/passcode_screen.dart';


const Color customYellow = Color(0xFFE0A800);

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Minhas Senhas',
        'icon': Icons.lock_outline,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PasscodeScreen()))
      },
      {
        'title': 'Nova Senha',
        'icon': Icons.add_circle_outline,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddPassScreen()))
      },
      {
        'title': 'Gerar Senha',
        'icon': Icons.vpn_key_outlined,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const GeneratorScreen()))
      },
      {
        'title': 'Carteira Digital',
        'icon': Icons.folder_copy_outlined,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FolderScreen()))
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        // Usamos o widget de card privado
        return _MenuItemCard(
          title: item['title'],
          icon: item['icon'],
          onTap: item['onTap'],
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItemCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: customYellow.withAlpha(26),
              child: Icon(icon, size: 28, color: customYellow),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}