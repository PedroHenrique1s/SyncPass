// arquivo_modificado: widgets/folder_accordion_list.dart

import 'package:flutter/material.dart';
// Importe seus modelos e serviços
import 'package:sync_pass/Feature/Folder/Services/folder_firestore_service.dart';
import 'package:sync_pass/Feature/Folder/Services/folder_storage_service.dart';

const Color customYellow = Color(0xFFE0A800);

// Não precisamos mais da classe 'CategoriaAgrupada', usamos o 'CategoryModel'
class FolderAccordionList extends StatefulWidget {
  const FolderAccordionList({super.key});

  @override
  State<FolderAccordionList> createState() => _FolderAccordionListState();
}

class _FolderAccordionListState extends State<FolderAccordionList> {
  // --- FUNÇÕES AUXILIARES DE ÍCONE ---
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'badge':
        return Icons.badge;
      case 'credit_card':
        return Icons.credit_card;
      case 'drive_eta':
        return Icons.drive_eta;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'folder_open':
        return Icons.folder_open;
      default:
        return Icons.folder;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  // --- FUNÇÃO DE DELETAR DOCUMENTO (sem mudanças) ---
  void _handleDeleteDocument(DocumentModel doc) async {
    // Confirmação
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja excluir o arquivo "${doc.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // 1. Deletar do Storage
    final bool storageSuccess = await FolderStorageService.deleteFile(doc.fileUrl);

    // 2. Deletar do Firestore
    if (storageSuccess) {
      await FolderFirestoreService.deleteDocument(doc.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento excluído.'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir arquivo.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- STREAMBUILDER NÍVEL 1: BUSCAR AS CATEGORIAS ---
    return StreamBuilder<List<CategoryModel>>(
      stream: FolderFirestoreService.getCategories(),
      builder: (context, categorySnapshot) {
        // Estado de Carregamento
        if (categorySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: customYellow));
        }

        // Estado de Erro
        if (categorySnapshot.hasError) {
          debugPrint('Erro no Stream (Categorias): ${categorySnapshot.error}');
          return const Center(child: Text('Erro ao carregar categorias.'));
        }

        // Estado Vazio (sem categorias cadastradas)
        if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhuma categoria criada',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  'Toque no botão + para adicionar sua primeira categoria',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // SUCESSO! Temos a lista de categorias
        final List<CategoryModel> categories = categorySnapshot.data!;

        // --- STREAMBUILDER NÍVEL 2: BUSCAR OS DOCUMENTOS ---
        // Agora que temos as categorias, buscamos TODOS os documentos
        return StreamBuilder<List<DocumentModel>>(
          stream: FolderFirestoreService.getDocuments(),
          builder: (context, docSnapshot) {
            
            // Se o docSnapshot está carregando, não bloqueamos a tela,
            // apenas usamos uma lista vazia por enquanto.
            final List<DocumentModel> allDocuments = docSnapshot.data ?? [];

            // --- LÓGICA DE AGRUPAMENTO (DENTRO DO BUILD) ---
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: categories.length, // A lista é baseada nas CATEGORIAS
              itemBuilder: (context, index) {
                final category = categories[index];

                // Filtra os documentos SÓ para esta categoria
                final List<DocumentModel> docsForThisCategory = allDocuments
                    .where((doc) => doc.category == category.name)
                    .toList();
                
                // Passa o CategoryModel e a lista de documentos filtrada
                return _buildExpansionTile(category, docsForThisCategory);
              },
            );
          },
        );
      },
    );
  }

  // --- WIDGET DA SANFONA (MODIFICADO) ---
  Widget _buildExpansionTile(CategoryModel categoria, List<DocumentModel> documentos) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      // --- Início da Modificação ---
      child: Theme(
        // Copia o tema atual e sobrescreve a cor do divisor
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          // --- Fim da Modificação ---
      
          // Usa os dados do CategoryModel
          leading: Icon(_getCategoryIcon(categoria.icon), color: customYellow, size: 28),
          title: Text(
            categoria.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
          // Usa a lista de documentos filtrada
          subtitle: Text('${documentos.length} documento(s)'),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          iconColor: customYellow,
          collapsedIconColor: Colors.grey[600],

          // --- FILHOS (LISTA DE DOCUMENTOS) ---
          children: documentos.isEmpty
              ? [
                  // Mostra esta mensagem se a categoria estiver vazia
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Nenhum documento nesta categoria.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                ]
              : documentos.map((doc) {
                  // Mapeia os documentos filtrados
                  return ListTile(
                    leading: Icon(_getFileTypeIcon(doc.type), color: Colors.grey[700]),
                    title: Text(doc.name, style: const TextStyle(fontSize: 15)),
                    subtitle: Text('Tamanho: ${doc.size}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 22),
                      onPressed: () => _handleDeleteDocument(doc),
                    ),
                    onTap: () {
                      debugPrint('Abrir: ${doc.fileUrl}');
                    },
                  );
                }).toList(),
        ),
      ),
    );
  }
}