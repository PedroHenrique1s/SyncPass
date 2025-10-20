import 'package:flutter/material.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderDocumentList extends StatelessWidget {
  FolderDocumentList({super.key});

  // Lista vazia - depois vai buscar do Firebase
  final List<Map<String, dynamic>> documents = [];

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _DocumentCard(
          name: doc['name'],
          category: doc['category'],
          type: doc['type'],
          date: doc['date'],
          size: doc['size'],
          onTap: () {
            _showDocumentOptions(context, doc);
          },
        );
      },
    );
  }

  void _showDocumentOptions(BuildContext context, Map<String, dynamic> doc) {
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
            Text(
              doc['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.remove_red_eye,
              title: 'Visualizar',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _OptionTile(
              icon: Icons.share,
              title: 'Compartilhar',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _OptionTile(
              icon: Icons.download,
              title: 'Baixar',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _OptionTile(
              icon: Icons.delete,
              title: 'Excluir',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String name;
  final String category;
  final String type;
  final String date;
  final String size;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.name,
    required this.category,
    required this.type,
    required this.date,
    required this.size,
    required this.onTap,
  });

  IconData _getIcon() {
    return type == 'pdf' ? Icons.picture_as_pdf : Icons.image;
  }

  Color _getIconColor() {
    return type == 'pdf' ? Colors.red : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconColor().withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: customYellow.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: customYellow.withAlpha(230),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$date • $size',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum documento adicionado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.black87;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        title,
        style: TextStyle(
          color: effectiveColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}