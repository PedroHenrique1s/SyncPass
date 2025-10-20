/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FolderFilePickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  // Tirar foto com a câmera
  static Future<File?> pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
      return null;
    }
  }

  // Escolher imagem da galeria
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao escolher imagem: $e');
      return null;
    }
  }

  // Escolher arquivo PDF
  static Future<File?> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao escolher PDF: $e');
      return null;
    }
  }

  // Verificar tamanho do arquivo (máximo 10MB)
  static bool isValidFileSize(File file) {
    final bytes = file.lengthSync();
    final mb = bytes / (1024 * 1024);
    return mb <= 10;
  }

  // Formatar tamanho do arquivo
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
*/