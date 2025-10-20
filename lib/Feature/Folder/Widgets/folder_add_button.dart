import 'package:flutter/material.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderAddButton extends StatelessWidget {
  const FolderAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddOptions(context),
      backgroundColor: customYellow,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Adicionar',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Adicionar Documento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _AddOptionCard(
              icon: Icons.camera_alt,
              title: 'Tirar Foto',
              subtitle: 'Use a câmera do dispositivo',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                // Implementar captura de foto
                _showCategorySelector(context, 'camera');
              },
            ),
            const SizedBox(height: 12),
            _AddOptionCard(
              icon: Icons.photo_library,
              title: 'Galeria',
              subtitle: 'Escolher da galeria',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                // Implementar seleção da galeria
                _showCategorySelector(context, 'gallery');
              },
            ),
            const SizedBox(height: 12),
            _AddOptionCard(
              icon: Icons.picture_as_pdf,
              title: 'Arquivo PDF',
              subtitle: 'Selecionar PDF do dispositivo',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                // Implementar seleção de PDF
                _showCategorySelector(context, 'pdf');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCategorySelector(BuildContext context, String sourceType) {
    final categories = ['RG', 'CPF', 'CNH', 'Comprovantes', 'Outros'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Selecione a Categoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...categories.map((category) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: customYellow.withAlpha(26),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: customYellow,
                    ),
                  ),
                  title: Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    // Aqui você vai implementar o upload real
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Upload de $sourceType para categoria $category',
                        ),
                        backgroundColor: customYellow,
                      ),
                    );
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'RG':
        return Icons.badge;
      case 'CPF':
        return Icons.credit_card;
      case 'CNH':
        return Icons.drive_eta;
      case 'Comprovantes':
        return Icons.receipt_long;
      default:
        return Icons.folder;
    }
  }
}

class _AddOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AddOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}