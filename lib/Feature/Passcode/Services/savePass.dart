import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_pass/Feature/AddPass/Models/password_type.dart'; 

class PasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constante para o nome da coleção
  static const String _collectionName = 'passwords';

  // =======================================================
  // CREATE - Salvar nova senha
  // =======================================================
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
      // Usa a constante _collectionName
      await _firestore.collection(_collectionName).add(dataToSave); 
    } catch (e) {
      throw Exception('Erro ao salvar no Firestore: ${e.toString()}');
    }
  }

  // =======================================================
  // READ - Obter stream de senhas
  // =======================================================
  Stream<QuerySnapshot> getPasswordsStream() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
      .collection(_collectionName) // Usa a constante
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
  }

  // =======================================================
  // UPDATE - Atualizar senha existente (NOVO MÉTODO)
  // =======================================================
  Future<void> updatePassword(String documentId, Map<String, dynamic> data) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    // Adiciona um timestamp de atualização
    data['updatedAt'] = FieldValue.serverTimestamp();

    try {
      await _firestore.collection(_collectionName).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar no Firestore: ${e.toString()}');
    }
  }

  // =======================================================
  // DELETE - Excluir senha (NOVO MÉTODO)
  // =======================================================
  Future<void> deletePassword(String documentId) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    try {
      await _firestore.collection(_collectionName).doc(documentId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir no Firestore: ${e.toString()}');
    }
  }
}