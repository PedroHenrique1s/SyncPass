/*import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FolderStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload de arquivo para o Firebase Storage
  static Future<String?> uploadFile({
    required File file,
    required String category,
    required String fileName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('Usuário não autenticado');
        return null;
      }

      // Caminho: users/{userId}/documents/{category}/{timestamp}_{fileName}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageFileName = '${timestamp}_$fileName';
      
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('documents')
          .child(category)
          .child(storageFileName);

      // Upload do arquivo
      final uploadTask = ref.putFile(file);
      
      // Aguardar conclusão
      final snapshot = await uploadTask;
      
      // Obter URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Upload concluído: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      debugPrint('Erro ao fazer upload: $e');
      return null;
    }
  }

  // Deletar arquivo do Firebase Storage
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('Arquivo deletado com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar arquivo: $e');
      return false;
    }
  }

  // Download de arquivo (retorna o caminho local temporário)
  static Future<File?> downloadFile(String fileUrl, String fileName) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final Directory tempDir = Directory.systemTemp;
      final File tempFile = File('${tempDir.path}/$fileName');
      
      await ref.writeToFile(tempFile);
      debugPrint('Arquivo baixado: ${tempFile.path}');
      return tempFile;
      
    } catch (e) {
      debugPrint('Erro ao baixar arquivo: $e');
      return null;
    }
  }
}
*/