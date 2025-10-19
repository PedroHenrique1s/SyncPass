import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:math';

const Color customYellow = Color(0xFFEEBF3A);

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = false;
  double _passwordLength = 16;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    String availableChars = '';
    if (_includeUppercase) availableChars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_includeLowercase) availableChars += 'abcdefghijklmnopqrstuvwxyz';
    if (_includeNumbers) availableChars += '0123456789';
    if (_includeSymbols) availableChars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (availableChars.isEmpty) {
      setState(() {
        _generatedPassword = 'Selecione uma opção!';
      });
      return;
    }

    final Random random = Random.secure(); 
    final newPassword = String.fromCharCodes(Iterable.generate(
      _passwordLength.round(),
      (_) => availableChars.codeUnitAt(random.nextInt(availableChars.length)),
    ));

    setState(() {
      _generatedPassword = newPassword;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty && _generatedPassword != 'Selecione uma opção!') {
      Clipboard.setData(ClipboardData(text: _generatedPassword)).then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha copiada para a área de transferência!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gerador de Senhas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
                elevation: 0, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _generatedPassword,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, 
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: customYellow), 
                        onPressed: _generatePassword,
                        tooltip: 'Gerar Nova Senha',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy_rounded, size: 20),
              label: const Text('Copiar Senha'),
              style: ElevatedButton.styleFrom(
                backgroundColor: customYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),

            _buildSectionTitle('Opções'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
               children: [
                  SwitchListTile(
                    title: const Text('Letras Maiúsculas (A-Z)'),
                    value: _includeUppercase,
                    onChanged: (value) => setState(() { _includeUppercase = value; _generatePassword(); }),
                    activeThumbColor: customYellow,
                    activeTrackColor: customYellow.withAlpha(102),
                  ),
                  SwitchListTile(
                    title: const Text('Letras Minúsculas (a-z)'),
                    value: _includeLowercase,
                    onChanged: (value) => setState(() { _includeLowercase = value; _generatePassword(); }),
                    activeThumbColor: customYellow,
                    activeTrackColor: customYellow.withAlpha(102),
                  ),
                  SwitchListTile(
                    title: const Text('Números (0-9)'),
                    value: _includeNumbers,
                    onChanged: (value) => setState(() { _includeNumbers = value; _generatePassword(); }),
                    activeThumbColor: customYellow,
                    activeTrackColor: customYellow.withAlpha(102),
                  ),
                  SwitchListTile(
                    title: const Text('Símbolos (!@#\$%)'),
                    value: _includeSymbols,
                    onChanged: (value) => setState(() { _includeSymbols = value; _generatePassword(); }),
                    activeThumbColor: customYellow,
                    activeTrackColor: customYellow.withAlpha(102),
                  ),
                ],
              ),
            ),

            // --- SEÇÃO DE TAMANHO ---
            _buildSectionTitle('Tamanho da Senha: ${_passwordLength.round()}'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Slider(
                value: _passwordLength,
                min: 6,
                max: 32,
                divisions: 26,
                label: _passwordLength.round().toString(),
                activeColor: customYellow,
                inactiveColor: Colors.grey[300],
                onChanged: (value) => setState(() { _passwordLength = value; _generatePassword(); }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}