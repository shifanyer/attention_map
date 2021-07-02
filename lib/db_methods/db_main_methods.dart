import 'dart:io';

import 'package:attention_map/enums/enumMethods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'fire_storages/fire_storage_service.dart';

class DbMainMethods {
  static Future<void> uploadPoint(LatLng pointCoordinates, MarkerType markerType, List<String> centers) async {
    var pointType = EnumMethods.enumToString(markerType);
    for (var center in centers) {
      var newFile = FirebaseDatabase.instance.reference().child(center).child(pointType).push();
      newFile.child('coordX').set(pointCoordinates.latitude);
      newFile.child('coordY').set(pointCoordinates.longitude);
      newFile.child('confirms').set(1);
      newFile.child('creation_time').set(DateTime.now().millisecondsSinceEpoch);
      newFile.child('last_confirm_time').set(DateTime.now().millisecondsSinceEpoch);
    }
  }

  static Future<List<MarkerInfo>> downloadPoints(List<String> centers) async {
    var markers = <MarkerInfo>[];
    for (var center in centers) {
      DatabaseReference camerasDatabaseReference = FirebaseDatabase.instance.reference().child(center);
      var radiusSnapshot = await camerasDatabaseReference.once();
      for (var markerType in MarkerType.values) {
        var typedMap = radiusSnapshot.value[EnumMethods.enumToString(markerType)];
        for (var point in typedMap?.values ?? []) {
          var pointCoordinates = LatLng(point['coordX'], point['coordY']);
          var confirmsNumber = point['confirms'];
          var lastTimeConfirmation = point['last_confirm_time'];
          var newPoint = MarkerInfo(
              markerType: markerType,
              coordinates: pointCoordinates,
              confirms: confirmsNumber,
              lastTimeConfirmation: lastTimeConfirmation);
          markers.add(newPoint);
        }
      }
    }
    return markers;
  }

  static Future<Map> downloadPerson(String personID) async {
    DatabaseReference person = FirebaseDatabase.instance.reference().child(personID).child('person_information');
    var info = await person.once();
    return info.value;
  }
}
