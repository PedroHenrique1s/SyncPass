import 'package:flutter/material.dart';

import 'package:sync_pass/Feature/Folder/Widgets/folder_header.dart';
import 'package:sync_pass/Feature/Folder/Widgets/folder_categories.dart';
import 'package:sync_pass/Feature/Folder/Widgets/folder_document_list.dart';
import 'package:sync_pass/Feature/Folder/Widgets/folder_add_button.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Meus Documentos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: customYellow.withAlpha(102),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const FolderHeader(),
          const SizedBox(height: 16),
          const FolderCategories(),
          const SizedBox(height: 16),
          Expanded(
            child: FolderDocumentList(),
          ),
        ],
      ),
      floatingActionButton: const FolderAddButton(),
    );
  }
}