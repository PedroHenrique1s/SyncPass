// generator_screen.dart

import 'package:flutter/material.dart';
import 'dart:math'; // Para a lógica de geração de senha

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  // Estado dos checkboxes
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = false;
  
  // Tamanho da senha
  double _passwordLength = 12;
  
  // Senha gerada
  String _generatedPassword = '';

  // Lógica para gerar a senha
  void _generatePassword() {
    String availableChars = '';
    if (_includeUppercase) availableChars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_includeLowercase) availableChars += 'abcdefghijklmnopqrstuvwxyz';
    if (_includeNumbers) availableChars += '0123456789';
    if (_includeSymbols) availableChars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (availableChars.isEmpty) {
      setState(() {
        _generatedPassword = 'Selecione pelo menos um tipo de caractere.';
      });
      return;
    }

    final Random random = Random();
    String newPassword = '';
    for (int i = 0; i < _passwordLength.round(); i++) {
      newPassword += availableChars[random.nextInt(availableChars.length)];
    }

    setState(() {
      _generatedPassword = newPassword;
    });
  }

  @override
  void initState() {
    super.initState();
    // Gera a senha inicial ao carregar a tela
    _generatePassword();
  }
  
  // Widget para copiar a senha (simulado)
  void _copyToClipboard() {
    // Implemente a lógica de copiar para a área de transferência
    // Flutter: `Clipboard.setData(ClipboardData(text: _generatedPassword))`
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Senha copiada: $_generatedPassword')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador de Senhas', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exibição da senha
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _generatedPassword,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            // Botão para copiar
            ElevatedButton.icon(
              onPressed: _generatedPassword.isNotEmpty ? _copyToClipboard : null,
              icon: const Icon(Icons.copy),
              label: const Text('Copiar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFE0A800),
              ),
            ),
            const SizedBox(height: 30),

            // Opções de caracteres
            const Text(
              'Opções de Caracteres',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            CheckboxListTile(
              title: const Text('Incluir letras maiúsculas (A-Z)'),
              value: _includeUppercase,
              onChanged: (bool? value) {
                setState(() {
                  _includeUppercase = value!;
                  _generatePassword();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Incluir letras minúsculas (a-z)'),
              value: _includeLowercase,
              onChanged: (bool? value) {
                setState(() {
                  _includeLowercase = value!;
                  _generatePassword();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Incluir números (0-9)'),
              value: _includeNumbers,
              onChanged: (bool? value) {
                setState(() {
                  _includeNumbers = value!;
                  _generatePassword();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Incluir símbolos (!@#\$%)'),
              value: _includeSymbols,
              onChanged: (bool? value) {
                setState(() {
                  _includeSymbols = value!;
                  _generatePassword();
                });
              },
            ),
            const SizedBox(height: 30),

            // Slider para o tamanho da senha
            const Text(
              'Tamanho da Senha',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Slider(
              value: _passwordLength,
              min: 4,
              max: 32,
              divisions: 28,
              label: _passwordLength.round().toString(),
              activeColor: const Color(0xFFE0A800),
              onChanged: (double value) {
                setState(() {
                  _passwordLength = value;
                  _generatePassword();
                });
              },
            ),
            Text(
              'Comprimento: ${_passwordLength.round()}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}