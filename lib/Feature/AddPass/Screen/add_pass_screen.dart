// add_pass_screen.dart

import 'package:flutter/material.dart';

class AddPassScreen extends StatelessWidget {
  const AddPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Senha', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhes da nova senha:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Campo para o nome do serviço (ex: Google, Netflix)
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Serviço/Site',
                hintText: 'Ex: Google, Instagram',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.public, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),

            // Campo para o nome de usuário/email
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nome de Usuário/Email',
                hintText: 'seu_email@dominio.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),

            // Campo para a senha
            TextFormField(
              obscureText: true, // Para esconder a senha
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility_off, color: Colors.grey),
                  onPressed: () {
                    // TODO: Implementar a lógica para mostrar/esconder a senha
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Botão para salvar
            SizedBox(
              width: double.infinity, // Ocupa a largura total
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar a lógica para salvar a senha
                  // Por enquanto, apenas feche a tela
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senha salva com sucesso! (Simulado)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0A800), // Cor amarela
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Salvar Senha', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}