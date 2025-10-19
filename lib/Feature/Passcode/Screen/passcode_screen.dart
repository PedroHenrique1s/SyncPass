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

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final item = PasswordItem.fromDocument(document);
              return PasswordListItem(item: item);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPassScreen()),
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