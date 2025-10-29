import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// Verifique se os caminhos dos seus serviços estão corretos
import 'package:sync_pass/Feature/Folder/Services/folder_file_picker_service.dart';
import 'package:sync_pass/Feature/Folder/Services/folder_storage_service.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderAddButton extends StatelessWidget {
  const FolderAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (build function sem alterações)
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
      // 2. Renomeámos o 'context' do builder para 'modalBuilderContext'
      builder: (modalBuilderContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (Handle, Título, etc. - sem mudanças)
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
                // 3. Usamos o 'modalBuilderContext' para fechar o modal
                Navigator.pop(modalBuilderContext);
                
                // 4. Usamos o 'context' da PÁGINA para abrir o novo modal
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
                // 3. Usamos o 'modalBuilderContext'
                Navigator.pop(modalBuilderContext);
                
                // 4. Usamos o 'context' da PÁGINA
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
                // 3. Usamos o 'modalBuilderContext'
                Navigator.pop(modalBuilderContext);
                
                // 4. Usamos o 'context' da PÁGINA
                _showCategorySelector(context, 'pdf');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // A função _showCategorySelector ESTÁ CORRETA. Não mude nada aqui.
  void _showCategorySelector(BuildContext context, String sourceType) {
    final categories = ['RG', 'CPF', 'CNH', 'Comprovantes', 'Outros'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container( // Este 'modalContext' está correto
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (Handle, Título, etc.)
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
            ListView(
              shrinkWrap: true,
              children: categories
                  .map((category) => ListTile(
                        // ... (leading, title, trailing)
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
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        
                        onTap: () async {
                          // PASSO 1: PEGAR O FICHEIRO
                          File? file;
                          switch (sourceType) {
                            case 'camera':
                              file = await FolderFilePickerService.pickFromCamera();
                              break;
                            case 'gallery':
                              file = await FolderFilePickerService.pickFromGallery();
                              break;
                            case 'pdf':
                              file = await FolderFilePickerService.pickPDF();
                              break;
                          }

                          // PASSO 2: VALIDAR CONTEXTO E FICHEIRO
                          // 'modalContext' (do builder) e 'context' (da página)
                          if (!modalContext.mounted || !context.mounted) return;
                          Navigator.pop(modalContext); // Fecha o modal de categorias
                          
                          if (file == null) return; // Utilizador cancelou

                          // PASSO 3: VALIDAR TAMANHO
                          if (!FolderFilePickerService.isValidFileSize(file)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro: Ficheiro muito grande (Max 10MB).'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // PASSO 4: UPLOAD
                          final String fileName = p.basename(file.path);
                          final String? downloadUrl = await FolderStorageService.uploadFile(
                            file: file,
                            category: category,
                            fileName: fileName,
                          );

                          // PASSO 5: FEEDBACK
                          if (!context.mounted) return;
                          if (downloadUrl != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Upload para $category concluído!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // TODO: Salvar no Firestore
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao fazer upload para $category.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    // ... (Função sem alterações)
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