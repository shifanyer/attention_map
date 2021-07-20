import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  static Future<File> get _userData async {
    final path = await _localPath;
    return File('$path/userData.txt');
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

  static Future<void> writeUserData() async {
    final file = await _userData;
    file.writeAsStringSync(jsonEncode(globals.userData));
    // var writtenFile = json.decode((file?.readAsStringSync()) ?? '');
    // print('writtenFile: ${writtenFile}');
  }

  static Future<void> readUserData() async {
    try {
      final file = await _userData;
      Map writtenFile = json.decode((file?.readAsStringSync()) ?? '');
      globals.userData = writtenFile.map((key, value) {
            if (key == 'avatar') {
              List<int> avatarList = [];
              for (var item in value) {
                avatarList.add(item as int);
              }
              return MapEntry(key, Uint8List.fromList(avatarList));
            }
            return MapEntry(key, value);
          }) ??
          {};
      return true;
    } catch (e) {
      globals.userData = {};
      print('err: ${e}');
      return false;
    }
  }
}
