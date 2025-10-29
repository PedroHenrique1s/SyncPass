import 'package:flutter/material.dart';

// 1. IMPORTS NECESSÁRIOS
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatar datas

// 2. IMPORTE OS SEUS SERVIÇOS (para o "Excluir")
// (Verifique se estes caminhos estão corretos)
import 'package:sync_pass/Feature/Folder/Services/folder_storage_service.dart';

const Color customYellow = Color(0xFFE0A800);

class FolderDocumentList extends StatelessWidget {
  FolderDocumentList({super.key});

  // 3. REMOVEMOS a lista "chumbada"
  // final List<Map<String, dynamic>> documents = []; // <--- ISTO SAIU

  // 4. Instâncias do Auth e Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // Se o utilizador não estiver logado, não há nada para mostrar
    if (user == null) {
      return const _EmptyState();
    }

    // 5. Este é o "stream" (a fonte de dados ao vivo)
    final Stream<QuerySnapshot> documentStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('documents')
        .orderBy('createdAt', descending: true) // Mostrar os mais recentes primeiro
        .snapshots(); // '.snapshots()' é o que o torna "ao vivo"

    // 6. Usamos o STREAMBUILDER
    return StreamBuilder<QuerySnapshot>(
      stream: documentStream,
      builder: (context, snapshot) {
        
        // Estado de Carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: customYellow));
        }

        // Estado de Erro
        if (snapshot.hasError) {
          debugPrint('Erro no StreamBuilder: ${snapshot.error}');
          return const Center(child: Text('Erro ao carregar documentos.'));
        }

        // Estado Vazio (sem documentos)
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const _EmptyState();
        }

        // 7. SUCESSO! Temos dados.
        final documents = snapshot.data!.docs; // Esta é a sua lista de documentos

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            
            // Pega o documento atual e os seus dados
            final doc = documents[index];
            final docData = doc.data() as Map<String, dynamic>;

            // 8. FORMATAR A DATA
            // Pega o Timestamp e formata para dd/MM/yyyy
            final Timestamp timestamp = docData['createdAt'] ?? Timestamp.now();
            final String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());

            return _DocumentCard(
              // Usamos '.get' para segurança caso o campo não exista
              name: docData.get('fileName', 'Sem nome'),
              category: docData.get('category', 'Outros'),
              type: docData.get('type', 'image'),
              date: formattedDate, // Passamos a data formatada
              size: docData.get('formattedSize', '0 KB'),
              onTap: () {
                // Passamos o ID do documento e os dados para o modal
                _showDocumentOptions(context, doc.id, docData);
              },
            );
          },
        );
      },
    );
  }

  // 9. ATUALIZÁMOS A FUNÇÃO para receber o ID e os DADOS
  void _showDocumentOptions(BuildContext context, String docId, Map<String, dynamic> docData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (Handle e Título do modal - sem mudanças)
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
              docData.get('fileName', 'Documento'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.remove_red_eye,
              title: 'Visualizar',
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Implementar visualização (ex: com 'open_file' ou 'url_launcher')
              },
            ),
            _OptionTile(
              icon: Icons.share,
              title: 'Compartilhar',
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Implementar partilha (ex: com 'share_plus')
              },
            ),
            _OptionTile(
              icon: Icons.download,
              title: 'Baixar',
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Implementar download (pode usar o seu FolderStorageService.downloadFile)
              },
            ),
            _OptionTile(
              icon: Icons.delete,
              title: 'Excluir',
              color: Colors.red,
              onTap: () async {
                // 10. LÓGICA DE EXCLUIR
                try {
                  // Fecha o modal ANTES de apagar
                  Navigator.pop(modalContext);

                  // Passo 1: Apagar o ficheiro do Storage
                  final fileUrl = docData.get('url', null);
                  if (fileUrl != null) {
                    await FolderStorageService.deleteFile(fileUrl);
                  }

                  // Passo 2: Apagar o registo do Firestore
                  final user = _auth.currentUser;
                  if (user != null) {
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('documents')
                        .doc(docId) // Usamos o ID do documento
                        .delete();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Documento excluído com sucesso.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Erro ao excluir: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao excluir o documento.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 11. HELPER DE SEGURANÇA (para evitar erros de null)
extension SafeGet on Map<String, dynamic> {
  dynamic get(String key, dynamic defaultValue) {
    return containsKey(key) ? this[key] : defaultValue;
  }
}

//
// O WIDGET _DocumentCard NÃO MUDA NADA
//
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

//
// O WIDGET _EmptyState NÃO MUDA NADA
//
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

//
// O WIDGET _OptionTile NÃO MUDA NADA
//
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