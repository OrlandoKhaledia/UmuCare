import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Uploads a file and returns the download URL
  Future<String> uploadFile(File file, String path) async {
    try {
      final uploadTask = _storage.ref().child(path).putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) print("StorageService Error: ${e.code}");
      throw Exception('Failed to upload file: ${e.message}');
    }
  }
}