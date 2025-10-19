import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String password,
    required String cpf, 
  }) async {
    // PASSO 1: Verificar se o CPF já existe no Firestore
    final existingUser = await _firestore
        .collection('users')
        .where('cpf', isEqualTo: cpf)
        .limit(1)
        .get();

    if (existingUser.docs.isNotEmpty) {
      throw FirebaseAuthException(code: 'cpf-already-in-use');
    }

    // PASSO 2: Criar o utilizador no Firebase Authentication
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final User? user = userCredential.user;

    if (user == null) {
      throw Exception('Não foi possível criar o usuário. Tente novamente.');
    }

    // PASSO 3: Salvar os dados adicionais no Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'cpf': cpf, // Salva o CPF limpo
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}