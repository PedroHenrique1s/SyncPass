import 'package:flutter/material.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderCategories extends StatefulWidget {
  const FolderCategories({super.key});

  @override
  State<FolderCategories> createState() => _FolderCategoriesState();
}

class _FolderCategoriesState extends State<FolderCategories> {
  String selectedCategory = 'Todos';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Todos', 'icon': Icons.folder_open},
    {'name': 'RG', 'icon': Icons.badge},
    {'name': 'CPF', 'icon': Icons.credit_card},
    {'name': 'CNH', 'icon': Icons.drive_eta},
    {'name': 'Comprovantes', 'icon': Icons.receipt_long},
    {'name': 'Outros', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];

          return _CategoryCard(
            name: category['name'],
            icon: category['icon'],
            isSelected: isSelected,
            onTap: () {
              setState(() {
                selectedCategory = category['name'];
              });
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? customYellow : Colors.white,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : customYellow,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}