// Em: Feature/AddPass/Services/savePass.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_pass/Feature/AddPass/Models/password_type.dart'; 

class PasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //
  // --- MÉTODO 1 (Da AddPassScreen) ---
  //
  Future<void> savePasswordData({
    required PasswordType type,
    required Map<String, dynamic> rawData,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    Map<String, dynamic> dataToSave = {
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': type.name,
      'title': rawData['title'] ?? '',
    };

    switch (type) {
      case PasswordType.login:
        dataToSave.addAll({
          'username': rawData['username'] ?? '',
          'password': rawData['password'] ?? ''
        });
        break;
      case PasswordType.card:
        dataToSave.addAll({
          'cardHolderName': rawData['cardHolderName'] ?? '',
          'cardNumber': rawData['cardNumber'] ?? '',
          'expiryDate': rawData['expiryDate'] ?? '',
          'cvv': rawData['cvv'] ?? '',
        });
        break;
      case PasswordType.generic:
        dataToSave.addAll({'password': rawData['password'] ?? ''});
        break;
    }

    try {
      await _firestore.collection('passwords').add(dataToSave);
    } catch (e) {
      throw Exception('Erro ao salvar no Firestore: ${e.toString()}');
    }
  }


  Stream<QuerySnapshot> getPasswordsStream() {
    final User? user = _auth.currentUser;

    if (user == null) {
      // Retorna um stream vazio se não houver usuário
      return const Stream.empty();
    }

    // Lógica que estava no initState da PasscodeScreen
    return _firestore
      .collection('passwords')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
  }
}