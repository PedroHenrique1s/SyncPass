import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_pass/Feature/AddPass/Models/password_type.dart';

class PasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Salva os dados da senha, tratando a lógica de qual
  /// dado salvar com base no tipo.
  Future<void> savePasswordData({
    required PasswordType type,
    required Map<String, dynamic> rawData,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    // 1. Monta o objeto base
    Map<String, dynamic> dataToSave = {
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': type.name,
      // 'title' é comum a todos
      'title': rawData['title'] ?? '',
    };

    // 2. Lógica de negócios (o switch) movida para cá
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

    // 3. Salva no banco de dados
    try {
      await _firestore.collection('passwords').add(dataToSave);
    } catch (e) {
      // Joga o erro para a UI tratar
      throw Exception('Erro ao salvar no Firestore: ${e.toString()}');
    }
  }
}
