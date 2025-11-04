import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordItem {
  // NOVO: ID do documento no Firestore, essencial para Editar e Excluir.
  final String documentId; 
  
  // NOVO: Dados originais do Firestore, úteis para pré-preencher a tela de edição.
  final Map<String, dynamic> rawData; 
  
  final String title;
  final String subtitle;
  final IconData iconData;
  final String textToCopy;
  final String copySuccessMessage;

  PasswordItem({
    required this.documentId, // NOVO
    required this.rawData,    // NOVO
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.textToCopy,
    required this.copySuccessMessage,
  });

  factory PasswordItem.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final String type = data['type'] ?? 'login';

    String title;
    String subtitle;
    IconData iconData;
    String textToCopy;
    String copySuccessMessage;

    switch (type) {
      case 'card':
        title = data['title'] ?? 'Cartão de Crédito';
        final cardNumber = data['cardNumber'] ?? '';
        subtitle = cardNumber.isNotEmpty
            ? 'Final •••• ${cardNumber.substring(cardNumber.length - 4)}'
            : 'Número não informado';
        iconData = Icons.credit_card;
        textToCopy = data['cardNumber'] ?? '';
        copySuccessMessage = 'Número do cartão copiado!';
        break;

      case 'generic':
        title = data['title'] ?? 'Senha Genérica';
        subtitle = 'Senha / Nota';
        iconData = Icons.key_outlined;
        textToCopy = data['password'] ?? '';
        copySuccessMessage = 'Senha copiada!';
        break;

      case 'login':
      default:
        title = data['title'] ?? 'Login';
        subtitle = data['username'] ?? 'Usuário não informado';
        iconData = Icons.public_outlined;
        textToCopy = data['password'] ?? '';
        copySuccessMessage = 'Senha de $title copiada!';
        break;
    }

    return PasswordItem(
      documentId: document.id,  // NOVO: Pega o ID do documento
      rawData: data,           // NOVO: Salva todos os dados
      title: title,
      subtitle: subtitle,
      iconData: iconData,
      textToCopy: textToCopy,
      copySuccessMessage: copySuccessMessage,
    );
  }
}