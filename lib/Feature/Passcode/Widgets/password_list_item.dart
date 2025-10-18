import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sync_pass/Feature/Passcode/Models/password_item.dart';

// Sua cor customizada (idealmente, mova para um arquivo de tema)
const Color customYellow = Color(0xFFE0A800);

class PasswordListItem extends StatelessWidget {
  final PasswordItem item;

  const PasswordListItem({super.key, required this.item});

  // Função de copiar movida para cá
  void _copyToClipboard(BuildContext context) {
    if (item.textToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: item.textToCopy)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(item.copySuccessMessage),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          // Corrigindo a depreciação 'withOpacity'
          backgroundColor: customYellow.withAlpha(38), // 0.15 * 255 = 38
          child: Icon(item.iconData, color: customYellow),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          item.subtitle,
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_outlined, size: 22, color: Colors.grey),
          onPressed: () => _copyToClipboard(context),
        ),
        onTap: () {
          // TODO: Implementar navegação para uma tela de detalhes/edição.
        },
      ),
    );
  }
}