import 'dart:convert';
import 'dart:io';

import 'package:attention_map/map_objects/marker_point.dart';
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

  static Future<File> get _userMarkers async {
    final path = await _localPath;
    return File('$path/userMarkers.txt');
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  static Future<void> writeUserDecisions() async {
    final file = await _userDecisions;

    // Write the file
    var stringDecisions = globals.userDecisions.map((MarkerId key, value) => MapEntry(key.value, value));
    file.writeAsStringSync(jsonEncode(stringDecisions));
    // print(writtenFile);
  }

  static Future<void> readUserDecisions() async {
    try {
      final file = await _userDecisions;
      Map writtenFile = json.decode((file?.readAsStringSync()) ?? '');
      globals.userDecisions = writtenFile.map((key, value) => MapEntry(MarkerId(key), value)) ?? {};
      return true;
    } catch (e) {
      // If encountering an error, return 0
      globals.userDecisions = {};
      print('err: ${e}');
      return false;
    }
  }

  static Future<void> writeUserMarkers() async {
    final file = await _userMarkers;
    file.writeAsStringSync(jsonEncode(globals.userMarkers.map((key, value) => MapEntry(key, value.toJson()))));
    // var writtenFile = json.decode((file?.readAsStringSync()) ?? '');
    // print('writtenFile: ${writtenFile}');
  }


  static Future<void> readUserMarkers() async {
    try {
      final file = await _userMarkers;
      Map writtenFile = json.decode((file?.readAsStringSync()) ?? '');
      globals.userMarkers = writtenFile.map((key, value) => MapEntry(key, MarkerInfo.fromJson(value))) ?? {};
      return true;
    } catch (e) {
      globals.userMarkers = {};
      print('err: ${e}');
      return false;
    }
  }

}