import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DocumentModel {
  final String id;
  final String name;
  final String category;
  final String type; // 'image' ou 'pdf'
  final String fileUrl;
  final String size;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.fileUrl,
    required this.size,
    required this.createdAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      size: map['size'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'type': type,
      'fileUrl': fileUrl,
      'size': size,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({required this.id, required this.name, required this.icon});

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'folder_open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}

class FolderFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> addDocument({
    required String name,
    required String category,
    required String type,
    required String fileUrl,
    required String size,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = DocumentModel(
        id: '',
        name: name,
        category: category,
        type: type,
        fileUrl: fileUrl,
        size: size,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('documents')
          .add(doc.toMap());

      debugPrint('Documento salvo no Firestore');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar documento: $e');
      return false;
    }
  }

  static Stream<List<DocumentModel>> getDocuments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DocumentModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  static Stream<List<DocumentModel>> getDocumentsByCategory(String category) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    if (category == 'Todos') {
      return getDocuments();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('documents')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DocumentModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  static Future<bool> deleteDocument(String documentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('documents')
          .doc(documentId)
          .delete();

      debugPrint('Documento deletado do Firestore');
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar documento: $e');
      return false;
    }
  }

  static Future<bool> updateDocumentName(String documentId, String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('documents')
          .doc(documentId)
          .update({'name': newName});

      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar documento: $e');
      return false;
    }
  }

  static Future<bool> addCategory({
    required String name,
    required String icon,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final existing = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('Categoria "$name" já existe.');
        return false;
      }

      final category = CategoryModel(id: '', name: name, icon: icon);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .add(category.toMap());

      debugPrint('Categoria "$name" salva no Firestore');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar categoria: $e');
      return false;
    }
  }

  static Stream<List<CategoryModel>> getCategories() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // NOVO MÉTODO: Deletar categoria
  static Future<bool> deleteCategory(String categoryId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .delete();

      debugPrint('Categoria deletada do Firestore');
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar categoria: $e');
      return false;
    }
  }
}