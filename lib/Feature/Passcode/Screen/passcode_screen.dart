import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_pass/Feature/AddPass/Screen/add_pass_screen.dart';
import 'package:sync_pass/Feature/Passcode/Models/password_item.dart';
import 'package:sync_pass/Feature/Passcode/Services/savePass.dart';
import 'package:sync_pass/Feature/Passcode/Widgets/password_list_item.dart';

const Color customYellow = Color(0xFFE0A800);

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  late final PasswordService _passwordService;
  Stream<QuerySnapshot>? _passwordsStream;

  @override
  void initState() {
    super.initState();
    _passwordService = PasswordService();
    _passwordsStream = _passwordService.getPasswordsStream();
  }

  // =======================================================
  // NOVAS FUNÇÕES DE AÇÃO (EDITAR E EXCLUIR)
  // =======================================================

  /// Função chamada pelo [PasswordListItem] quando "Excluir" é pressionado
  void _handleDelete(PasswordItem item) async {
    try {
      // Chama o serviço para excluir o item usando seu ID
      await _passwordService.deletePassword(item.documentId);
      
      // Feedback visual para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} excluído com sucesso!'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir ${item.title}: $e'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  /// Função chamada pelo [PasswordListItem] quando "Editar" é pressionado
  void _handleEdit(PasswordItem item) {
    // Navega para a tela de Adicionar/Editar, passando o item
    Navigator.push(
      context,
      MaterialPageRoute(
        // Passa o 'itemToEdit' para a AddPassScreen entrar em modo de edição
        builder: (context) => AddPassScreen(itemToEdit: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Meus Itens Salvos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _passwordsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // --- Seus tratamentos de estado (waiting, error, empty) ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: customYellow));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar os itens.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vpn_key_off_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum item encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const Text(
                    'Toque no botão + para adicionar o seu primeiro.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // =======================================================
          // CONSTRUÇÃO DA LISTA (MODIFICADO)
          // =======================================================
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final item = PasswordItem.fromDocument(document);
              
              // ATUALIZADO: Passando as funções de callback para o widget
              return PasswordListItem(
                item: item,
                onDelete: _handleDelete, // Passa a função de exclusão
                onEdit: _handleEdit,     // Passa a função de edição
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Chama AddPassScreen sem 'itemToEdit' (Modo Adição)
              builder: (context) => const AddPassScreen(),
            ),
          );
        },
        backgroundColor: customYellow,
        foregroundColor: Colors.black,
        tooltip: 'Adicionar Novo Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}