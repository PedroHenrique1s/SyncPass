import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sync_pass/Feature/Passcode/Models/password_item.dart';

const Color customYellow = Color(0xFFE0A800);

class PasswordListItem extends StatelessWidget {
  final PasswordItem item;
  
  // NOVO: Callbacks para as ações de edição e exclusão.
  final Function(PasswordItem item) onDelete;
  final Function(PasswordItem item) onEdit;

  // ATUALIZADO: Construtor agora requer as novas funções.
  const PasswordListItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  // Função de copiar (sem alterações)
  void _copyToClipboard(BuildContext context) {
    if (item.textToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: item.textToCopy)).then((_) {
        // Garante que o SnackBar apareça, mesmo após o pop do menu
        if (ScaffoldMessenger.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(item.copySuccessMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

  // NOVO: Função que mostra o Bottom Sheet com as opções
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              // O "Editar" foi movido para o onTap principal (toque curto),
              // mas pode ser mantido aqui se preferir.
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context); // Fecha o Bottom Sheet
                  onEdit(item); // Chama a função de edição passada
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: Text('Copiar ${item.rawData == 'card' ? 'Número' : 'Senha'}'),
                onTap: () {
                  Navigator.pop(context); // Fecha o Bottom Sheet
                  _copyToClipboard(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                title: const Text('Excluir', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Fecha o Bottom Sheet
                  _confirmDelete(context); // Pede confirmação antes de excluir
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // NOVO: Diálogo de confirmação para exclusão
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o item "${item.title}"? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o AlertDialog
                onDelete(item); // Chama a função de exclusão passada
              },
            ),
          ],
        );
      },
    );
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
        
        // ATUALIZADO: Ícone de "mais ações"
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 22, color: Colors.grey),
          onPressed: () => _showActionSheet(context),
        ),
        
        // ATUALIZADO: Toque curto agora chama a edição
        onTap: () {
          onEdit(item);
        },
      ),
    );
  }
}