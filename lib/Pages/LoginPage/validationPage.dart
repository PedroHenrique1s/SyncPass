import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../Utils/validationCPF.dart';

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final TextEditingController _cpfController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final cpfFormatter = MaskTextInputFormatter(
    mask: "###.###.###-##",
    filter: {"#": RegExp(r'[0-9]')},
  );

  void _login() {
    if (_formKey.currentState!.validate()) {
      String cpf = _cpfController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logando com CPF: $cpf")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão voltar
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
                // Título principal
                const Text(
                  "Boas-vindas ao SyncPass! Qual o seu CPF?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtítulo
                const Text(
                  "Precisamos dele para iniciar o seu cadastro ou acessar o aplicativo",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                // Campo CPF
                TextFormField(
                  controller: _cpfController,
                  inputFormatters: [cpfFormatter],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "000.000.000-00",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE0A800),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, digite o CPF";
                    }
                    if (value.length < 14) {
                      return "CPF deve ter 11 dígitos";
                    }
                    if (!isValidCPF(value)) {
                      return "CPF inválido";
                    }
                    return null;
                  },
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: _login,
                    backgroundColor: const Color(0xFFE0A800),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
