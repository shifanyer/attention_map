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
    var markerId = (pointCoordinates.latitude * 1000).truncate().toString() + (pointCoordinates.longitude * 1000).truncate().toString();
    for (var center in centers) {
      var newItem = FirebaseDatabase.instance.reference().child(center).child(pointType).child(markerId);
      var itemObj = await newItem.once();
      if (itemObj?.value == null) {
        newItem.child('coordX').set(pointCoordinates.latitude);
        newItem.child('coordY').set(pointCoordinates.longitude);
        newItem.child('confirms').set(1);
        newItem.child('creation_time').set(DateTime.now().millisecondsSinceEpoch);
        newItem.child('last_confirm_time').set(DateTime.now().millisecondsSinceEpoch);
      }
      else{
        newItem.child('confirms').set(itemObj.value['confirms'] + 1);
        newItem.child('last_confirm_time').set(DateTime.now().millisecondsSinceEpoch);
      }
    }
  }

  static Future<List<MarkerInfo>> downloadPointsList(List<String> centers) async {
    var markers = <MarkerInfo>[];
    for (var center in centers) {
      DatabaseReference camerasDatabaseReference = FirebaseDatabase.instance.reference().child(center);
      var radiusSnapshot = await camerasDatabaseReference.once();
      if (radiusSnapshot?.value == null){
        return [];
      }
      for (var markerType in MarkerType.values) {
        var typedMap = radiusSnapshot?.value[EnumMethods.enumToString(markerType)] ?? {};
        for (var point in typedMap?.values ?? []) {
          var pointCoordinates = LatLng(point['coordX'] * 1.0, point['coordY'] * 1.0);
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

  static newConfirm() {

  }

}
