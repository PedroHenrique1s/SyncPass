import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// Verifique se os caminhos dos seus serviços estão corretos
import 'package:sync_pass/Feature/Folder/Services/folder_file_picker_service.dart';
import 'package:sync_pass/Feature/Folder/Services/folder_firestore_service.dart';
import 'package:sync_pass/Feature/Folder/Services/folder_storage_service.dart';

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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalBuilderContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título
            const Text(
              'Adicionar Documento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Card 'Tirar Foto' (Completo)
            _AddOptionCard(
              icon: Icons.camera_alt,
              title: 'Tirar Foto',
              subtitle: 'Use a câmera do dispositivo',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(modalBuilderContext);
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
                Navigator.pop(modalBuilderContext);
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
                Navigator.pop(modalBuilderContext);
                _showCategorySelector(context, 'pdf');
              },
            ),
            const SizedBox(height: 12),

            _AddOptionCard(
              icon: Icons.create_new_folder_outlined,
              title: 'Nova Categoria',
              subtitle: 'Adicionar uma nova categoria',
              color: const Color.fromARGB(188, 187, 187, 16),
              onTap: () {
                Navigator.pop(modalBuilderContext);
                _showAddCategoryDialog(context);
              },
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    String selectedIcon = 'folder_open'; 
    final Map<String, IconData> categoryIcons = {
      'folder_open': Icons.folder_open,       
      'badge': Icons.badge,                
      'receipt_long': Icons.receipt_long,  
      'home': Icons.home,                  
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Text('Nova Categoria'),
              content: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome da Categoria',
                        hintText: 'Ex: Passaporte, Certidões',
                        prefixIcon:
                            Icon(Icons.edit_outlined, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none, 
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: customYellow, width: 2),
                        ),
                      ),
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Escolha um ícone',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: categoryIcons.entries.map((entry) {
                        final iconName = entry.key;
                        final iconData = entry.value;
                        final bool isSelected = (selectedIcon == iconName);

                        return GestureDetector(
                          onTap: () {
                            stfSetState(() {
                              selectedIcon = iconName;
                            });
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? customYellow.withAlpha(50)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? customYellow
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected
                                  ? customYellow
                                  : Colors.grey[700],
                              size: 28,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                // 6. Botões Estilizados
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customYellow,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Salvar'),
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    if (name.isEmpty) return; 

                    // Chamar o serviço para salvar
                    final bool success =
                        await FolderFirestoreService.addCategory(
                      name: name,
                      icon: selectedIcon,
                    );

                    if (!dialogContext.mounted || !context.mounted) return;
                    Navigator.pop(dialogContext); 

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Categoria criada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Erro: Esta categoria pode já existir.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCategorySelector(BuildContext context, String sourceType) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) { // Contexto do Modal
        return StreamBuilder<List<CategoryModel>>(
          stream: FolderFirestoreService.getCategories(), // LENDO DO FIREBASE!
          
          // --- A CORREÇÃO ESTÁ AQUI ---
          // Renomeie 'context' para 'streamContext'
          builder: (streamContext, snapshot) {
          // --- FIM DA CORREÇÃO ---

            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator(color: customYellow)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              content = const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'Nenhuma categoria encontrada.\nToque em "Nova Categoria" primeiro.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              // Temos categorias, montamos a lista
              final categories = snapshot.data!;
              content = ListView(
                shrinkWrap: true,
                children: categories.map((category) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: customYellow.withAlpha(26),
                      child: Icon(
                        _getCategoryIcon(category.icon), // Usa o ícone do modelo
                        color: customYellow,
                      ),
                    ),
                    title: Text(
                      category.name, // Usa o nome do modelo
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Agora, este 'context' refere-se ao 'context' da PÁGINA
                      _handleFileProcessing(
                        context: context, // <- Este é o 'context' da PÁGINA
                        modalContext: modalContext, // <- Este é o 'context' do MODAL
                        sourceType: sourceType,
                        categoryName: category.name, // Passa o nome da categoria
                      );
                    },
                  );
                }).toList(),
              );
            }

            // Estrutura do Modal
            return Container(
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
                  content, // Conteúdo dinâmico (Loading, Lista ou Vazio)
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleFileProcessing({
    required BuildContext context,
    required BuildContext modalContext,
    required String sourceType,
    required String categoryName,
  }) async {
    // PASSO 1: PEGAR O FICHEIRO E DEFINIR O TIPO
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

    // PASSO 2: VALIDAR CONTEXTO E FICHEIRO
    if (!modalContext.mounted || !context.mounted) return;
    Navigator.pop(modalContext); // Fecha o modal de categorias
    if (file == null) return; // Utilizador cancelou

    if (!FolderFilePickerService.isValidFileSize(file)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem muito grande'), backgroundColor: Colors.red),
      );
      return;
    }

    final String fileName = p.basename(file.path);
    final int fileSizeInBytes = file.lengthSync();
    final String formattedSize = _formatFileSize(fileSizeInBytes);

    // PASSO 4: UPLOAD PARA O STORAGE
    // (Mostra um loading)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enviando para $categoryName...')),
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Remove o "Enviando..."

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload para $categoryName concluído!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro Firestore'), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro Storage'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1048576) { // Menor que 1 MB
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = bytes / 1048576;
      return '${mb.toStringAsFixed(1)} MB';
    }
  }

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
        return Icons.folder; // Ícone padrão
    }
  }
}

// O widget _AddOptionCard não precisa de NENHUMA alteração
class _AddOptionCard extends StatelessWidget {
  // ... (código sem alterações)
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