import 'package:flutter/material.dart';

class FireStorageService extends ChangeNotifier {
  FireStorageService._();
  FireStorageService();

  static Future<dynamic> loadFromStorage(BuildContext context, List<String> imagePath) {
    throw ("Platform not found");
  }
}