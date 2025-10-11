// passcode_screen.dart

import 'package:flutter/material.dart';

class PasscodeScreen extends StatelessWidget {
  const PasscodeScreen({super.key});

  // Lista de exemplo para simular senhas salvas
  final List<Map<String, dynamic>> _dummyPasswords = const [
    {
      'service': 'Google',
      'username': 'meu.email@gmail.com',
    },
    {
      'service': 'Netflix',
      'username': 'nome.usuario',
    },
    {
      'service': 'GitHub',
      'username': 'meu-usuario-dev',
    },
    {
      'service': 'Nubank',
      'username': '000000000-00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Definindo a cor amarela customizada
    const Color customYellow = Color(0xFFE0A800);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Senhas', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _dummyPasswords.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma senha encontrada.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _dummyPasswords.length,
              itemBuilder: (context, index) {
                final password = _dummyPasswords[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock, color: customYellow),
                      title: Text(
                        password['service'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        password['username'],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          // TODO: Lógica para copiar a senha para a área de transferência
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Senha de ${password['service']} copiada.'),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        // TODO: Lógica para exibir a senha ou editar os detalhes
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Você clicou em ${password['service']}'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
    );
  }
}