import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FireStorageService extends ChangeNotifier {
  FireStorageService._();

  FireStorageService();

  static Future<dynamic> loadFromStorage(BuildContext context, List<String> imagePath) async {
    var FirebaseStorageImg = FirebaseStorage.instance.ref();
    for (var pathItem in imagePath) {
      FirebaseStorageImg = FirebaseStorageImg.child(pathItem);
    }
    return await FirebaseStorageImg.getDownloadURL();
  }
}
