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
        newItem.child('confirms').child('for').set(1);
        newItem.child('creation_time').set(DateTime.now().millisecondsSinceEpoch);
        newItem.child('last_confirm_time').set(DateTime.now().millisecondsSinceEpoch);
      } else {
        newItem.child('confirms').child('for').set(itemObj?.value['confirms']['for'] + 1);
        newItem.child('last_confirm_time').set(DateTime.now().millisecondsSinceEpoch);
      }
    }
  }

  static Future<void> subtractPoint(LatLng pointCoordinates, MarkerType markerType, List<String> centers) async {
    var pointType = EnumMethods.enumToString(markerType);
    var markerId = (pointCoordinates.latitude * 1000).truncate().toString() + (pointCoordinates.longitude * 1000).truncate().toString();
    for (var center in centers) {
      var newItem = FirebaseDatabase.instance.reference().child(center).child(pointType).child(markerId).child('confirms').child('against');
      var itemObj = await newItem.once();
      if (itemObj?.value != null) {
        newItem.set(itemObj.value + 1);
      } else {
        newItem.set(1);
      }
    }
  }

  static Future<List<MarkerInfo>> downloadPointsList(List<String> centers) async {
    var markers = <MarkerInfo>[];
    for (var center in centers) {
      DatabaseReference camerasDatabaseReference = FirebaseDatabase.instance.reference().child(center);
      var radiusSnapshot = await camerasDatabaseReference.once();
      if (radiusSnapshot?.value == null) {
        return [];
      }
      for (var markerType in MarkerType.values) {
        var typedMap = radiusSnapshot?.value[EnumMethods.enumToString(markerType)] ?? {};
        for (var point in typedMap?.values ?? []) {
          var pointCoordinates = LatLng(point['coordX'] * 1.0, point['coordY'] * 1.0);
          var confirmsForNumber = point['confirms']['for'] ?? 0;
          var confirmsAgainstNumber = point['confirms']['against'] ?? 0;
          var lastTimeConfirmation = point['last_confirm_time'];
          var newPoint = MarkerInfo(
              markerType: markerType,
              coordinates: pointCoordinates,
              confirmsFor: confirmsForNumber,
              confirmsAgainst: confirmsAgainstNumber,
              lastTimeConfirmation: lastTimeConfirmation);
          markers.add(newPoint);
        }
      }
    }
    return markers;
  }

  static plusConfirmsFor(MarkerInfo markerInfo, {int addValue = 1}) async {
    Set<String> centers = markerInfo.getCentersSet();
    var markerId = (markerInfo.coordinates.latitude * 1000).truncate().toString() + (markerInfo.coordinates.longitude * 1000).truncate().toString();
    for (var center in centers) {
      DatabaseReference itemConfirmsDatabaseReference = FirebaseDatabase.instance
          .reference()
          .child(center)
          .child(EnumMethods.enumToString(markerInfo.markerType))
          .child(markerId)
          .child('confirms')
          .child('for');
      var confirms = await itemConfirmsDatabaseReference.once();
      itemConfirmsDatabaseReference.set((confirms?.value ?? 0) + addValue);
    }
  }

  static plusConfirmsAgainst(MarkerInfo markerInfo, {int addValue = 1}) async {
    Set<String> centers = markerInfo.getCentersSet();
    var markerId = (markerInfo.coordinates.latitude * 1000).truncate().toString() + (markerInfo.coordinates.longitude * 1000).truncate().toString();
    for (var center in centers) {
      DatabaseReference itemConfirmsDatabaseReference = FirebaseDatabase.instance
          .reference()
          .child(center)
          .child(EnumMethods.enumToString(markerInfo.markerType))
          .child(markerId)
          .child('confirms')
          .child('against');
      var confirms = await itemConfirmsDatabaseReference.once();
      itemConfirmsDatabaseReference.set((confirms?.value ?? 0) + addValue);
    }
  }
}
