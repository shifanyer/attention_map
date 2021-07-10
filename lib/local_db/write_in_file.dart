import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../global/globals.dart' as globals;

class FileOperations {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _userDecisions async {
    final path = await _localPath;
    return File('$path/userDecisions.txt');
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  static Future<void> writeUserDecisions(Map<MarkerId, int> userDecisions) async {
    final file = await _userDecisions;

    // Write the file
    var stringDecisions = userDecisions.map((MarkerId key, value) => MapEntry(key.value, value));
    file.writeAsStringSync(jsonEncode(stringDecisions));
    // print(writtenFile);
  }

  static Future<void> readUserDecisions() async {
    try {
      final file = await _userDecisions;
      Map writtenFile = json.decode((file?.readAsStringSync()) ?? '');
      globals.userDecisions = writtenFile.map((key, value) => MapEntry(MarkerId(key), value)) ?? {};
      print('globals.userDecisions: ${globals.userDecisions} writtenFile: ${writtenFile}');
      return true;
    } catch (e) {
      // If encountering an error, return 0
      globals.userDecisions = {};
      print('err: ${e}');
      return false;
    }
  }

}