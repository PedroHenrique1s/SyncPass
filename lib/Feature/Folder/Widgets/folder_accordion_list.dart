import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sync_pass/Feature/Folder/Services/folder_firestore_service.dart';
import 'package:sync_pass/Feature/Folder/Services/folder_storage_service.dart';
import 'package:sync_pass/Feature/Folder/Services/folder_file_picker_service.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderAccordionList extends StatefulWidget {
  const FolderAccordionList({super.key});

  @override
  State<FolderAccordionList> createState() => _FolderAccordionListState();
}

class _FolderAccordionListState extends State<FolderAccordionList> {
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'badge':
        return Icons.badge_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'drive_eta':
        return Icons.drive_eta_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'folder_open':
        return Icons.folder_open_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _showImageViewer(BuildContext context, String imageUrl, String imageName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: customYellow,
                          strokeWidth: 3,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 60, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Erro ao carregar imagem',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  imageName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRenameDocument(DocumentModel doc) async {
    final TextEditingController nameController = TextEditingController(text: doc.name);

    final String? newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Renomear Arquivo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Novo nome',
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: customYellow, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: customYellow,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop(name);
              }
            },
          ),
        ],
      ),
    );

    if (newName == null || newName == doc.name || !mounted) return;

    final success = await FolderFirestoreService.updateDocumentName(doc.id, newName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Arquivo renomeado!' : 'Erro ao renomear'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _handleDeleteDocument(DocumentModel doc) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirmar Exclusão', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Tem certeza de que deseja excluir o arquivo "${doc.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final bool storageSuccess = await FolderStorageService.deleteFile(doc.fileUrl);

    if (storageSuccess) {
      await FolderFirestoreService.deleteDocument(doc.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Documento excluído.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao excluir arquivo.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showDocumentOptions(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              doc.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            _OptionTile(
              icon: Icons.visibility_outlined,
              title: 'Visualizar',
              onTap: () {
                Navigator.pop(modalContext);
                if (doc.type == 'image') {
                  _showImageViewer(context, doc.fileUrl, doc.name);
                } else if (doc.type == 'pdf') {
                  _showPdfViewer(context, doc.fileUrl, doc.name);
                }
              },
            ),
            _OptionTile(
              icon: Icons.edit_outlined,
              title: 'Renomear',
              onTap: () {
                Navigator.pop(modalContext);
                _handleRenameDocument(doc);
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              title: 'Excluir',
              color: Colors.red[400],
              onTap: () {
                Navigator.pop(modalContext);
                _handleDeleteDocument(doc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfViewer(BuildContext context, String pdfUrl, String pdfName) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pdfName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Visualizador de PDF',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Em breve disponível',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customYellow,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Abrir no Navegador', style: TextStyle(fontWeight: FontWeight.w600)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Funcionalidade em desenvolvimento'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeleteCategory(CategoryModel category, List<DocumentModel> documents) async {
    final String message = documents.isEmpty
        ? 'Tem certeza de que deseja excluir a categoria "${category.name}"?'
        : 'Esta categoria possui ${documents.length} documento(s). Deseja excluir a categoria e todos os documentos?';

    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirmar Exclusão', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Excluir Todos', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Excluindo...'),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    bool allDeleted = true;
    for (var doc in documents) {
      final storageSuccess = await FolderStorageService.deleteFile(doc.fileUrl);
      if (!storageSuccess) {
        allDeleted = false;
        continue;
      }
      await FolderFirestoreService.deleteDocument(doc.id);
    }

    await FolderFirestoreService.deleteCategory(category.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allDeleted
                ? (documents.isEmpty
                    ? 'Categoria excluída com sucesso.'
                    : 'Categoria e ${documents.length} documento(s) excluídos.')
                : 'Categoria excluída, mas alguns arquivos podem não ter sido removidos.',
          ),
          backgroundColor: allDeleted ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: FolderFirestoreService.getCategories(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: customYellow, strokeWidth: 3));
        }

        if (categorySnapshot.hasError) {
          debugPrint('Erro no Stream (Categorias): ${categorySnapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text('Erro ao carregar categorias.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: customYellow.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.folder_open_outlined, size: 80, color: customYellow.withOpacity(0.6)),
                ),
                const SizedBox(height: 24),
                const Text('Nenhuma categoria criada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(
                  'Toque no botão + para adicionar\nsua primeira categoria',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final List<CategoryModel> categories = categorySnapshot.data!;

        return StreamBuilder<List<DocumentModel>>(
          stream: FolderFirestoreService.getDocuments(),
          builder: (context, docSnapshot) {
            final List<DocumentModel> allDocuments = docSnapshot.data ?? [];

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final List<DocumentModel> docsForThisCategory = allDocuments
                    .where((doc) => doc.category == category.name)
                    .toList();
                
                return _buildExpansionTile(category, docsForThisCategory);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExpansionTile(CategoryModel categoria, List<DocumentModel> documentos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: customYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getCategoryIcon(categoria.icon), color: customYellow, size: 26),
            ),
            title: Text(
              categoria.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.3),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${documentos.length} documento(s)',
                style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: customYellow,
            collapsedIconColor: Colors.grey[400],
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showFilePickerForCategory(context, categoria.name),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Adicionar Arquivo', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customYellow,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red[400],
                        onPressed: () => _handleDeleteCategory(categoria, documentos),
                        tooltip: 'Excluir categoria',
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (documentos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Nenhum documento nesta categoria.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...documentos.map((doc) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getFileTypeIcon(doc.type), color: Colors.grey[700], size: 22),
                      ),
                      title: Text(
                        doc.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Tamanho: ${doc.size}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () => _showDocumentOptions(context, doc),
                        color: Colors.grey[600],
                      ),
                      onTap: () {
                        if (doc.type == 'image') {
                          _showImageViewer(context, doc.fileUrl, doc.name);
                        } else if (doc.type == 'pdf') {
                          _showPdfViewer(context, doc.fileUrl, doc.name);
                        }
                      },
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilePickerForCategory(BuildContext context, String categoryName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Adicionar em: $categoryName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
            const SizedBox(height: 24),
            _FileTypeOption(
              icon: Icons.camera_alt_outlined,
              title: 'Tirar Foto',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(modalContext);
                _handleFileUpload(context, categoryName, 'camera');
              },
            ),
            const SizedBox(height: 12),
            _FileTypeOption(
              icon: Icons.photo_library_outlined,
              title: 'Escolher da Galeria',
              color: Colors.green,
              onTap: () {
                Navigator.pop(modalContext);
                _handleFileUpload(context, categoryName, 'gallery');
              },
            ),
            const SizedBox(height: 12),
            _FileTypeOption(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Adicionar PDF',
              color: Colors.red,
              onTap: () {
                Navigator.pop(modalContext);
                _handleFileUpload(context, categoryName, 'pdf');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFileUpload(BuildContext context, String categoryName, String sourceType) async {
    File? file;
    String fileType;

    switch (sourceType) {
      case 'camera':
        file = await FolderFilePickerService.pickFromCamera();
        fileType = 'image';
        break;
      case 'gallery':
        file = await FolderFilePickerService.pickFromGallery();
        fileType = 'image';
        break;
      case 'pdf':
        file = await FolderFilePickerService.pickPDF();
        fileType = 'pdf';
        break;
      default:
        return;
    }

    if (!context.mounted || file == null) return;

    if (!FolderFilePickerService.isValidFileSize(file)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Arquivo muito grande (máx 10MB)'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final String fileName = p.basename(file.path);
    final int fileSizeInBytes = file.lengthSync();
    final String formattedSize = _formatFileSize(fileSizeInBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviando para $categoryName...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    final String? downloadUrl = await FolderStorageService.uploadFile(
      file: file,
      category: categoryName,
      fileName: fileName,
    );

    if (!context.mounted) return;

    if (downloadUrl != null) {
      final bool success = await FolderFirestoreService.addDocument(
        name: fileName,
        category: categoryName,
        type: fileType,
        fileUrl: downloadUrl,
        size: formattedSize,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo adicionado em $categoryName!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao salvar no banco de dados'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao fazer upload do arquivo'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1048576) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = bytes / 1048576;
      return '${mb.toStringAsFixed(1)} MB';
    }
  }
}

class _FileTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FileTypeOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
          ],
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: effectiveColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ),
      ),
    );
  }
}