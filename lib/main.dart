import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sync_pass/Feature/Login/Screen/login_screen.dart';
import 'package:sync_pass/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // CORREÇÃO: Adicionada a chamada para iniciar o app.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Senhas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:
            const Color(0xFFFAF9F6), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE0A800), 
          primary: const Color(0xFFE0A800),
          secondary: const Color(0xFF424242), 
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}