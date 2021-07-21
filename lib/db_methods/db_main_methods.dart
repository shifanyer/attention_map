import 'dart:io';
import 'dart:math';

import 'package:attention_map/enums/enumMethods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/local_db/write_in_file.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'fire_storages/fire_storage_service.dart';
import '../global/globals.dart' as globals;

class DbMainMethods {
  static Future<void> uploadPoint(LatLng pointCoordinates, MarkerType markerType, List<String> centers) async {
    var pointType = EnumMethods.enumToString(markerType);
    var markerId = (pointCoordinates.latitude * 1000).truncate().toString() + '_' + (pointCoordinates.longitude * 1000).truncate().toString();
    bool isUpload = true;
    var nowTime = DateTime.now().millisecondsSinceEpoch;
    var minDist = -1.0;
    var pointCenter = LatLng(0.0, 0.0);
    for (var center in centers) {
      var radiusCenter = LatLng(int.parse(center.split('_').first) / 10, int.parse(center.split('_').last) / 10);
      var dist = pow((radiusCenter.latitude - pointCoordinates.latitude), 2) + pow((radiusCenter.longitude - pointCoordinates.longitude), 2);
      if ((minDist == -1.0) || (dist < minDist)) {
        minDist = dist;
        pointCenter = radiusCenter;
      }
    }

    var pointCenterString = (pointCenter.latitude * 10).truncate().toString() + '_' + (pointCenter.longitude * 10).truncate().toString();

    var newItem = FirebaseDatabase.instance.reference().child(pointCenterString).child(pointType).child(markerId);
    var itemObj = await newItem.once();
    if (itemObj?.value == null) {
      if (isUpload) {
        var newMarker = MarkerInfo(
            markerType: markerType,
            coordinates: LatLng(pointCoordinates.latitude, pointCoordinates.longitude),
            confirmsFor: 1,
            confirmsAgainst: 0,
            lastTimeConfirmation: nowTime);
        globals.userMarkers[newMarker.getMarkerId().value] = newMarker;
        FileOperations.writeUserMarkers();
      }
      newItem.child('coordX').set(pointCoordinates.latitude);
      newItem.child('coordY').set(pointCoordinates.longitude);
      newItem.child('confirms').child('for').set(1);
      newItem.child('creation_time').set(nowTime);
      newItem.child('last_confirm_time').set(nowTime);
      newItem.child('descriptionText').set('');
      isUpload = false;
    } else {
      isUpload = false;
      newItem.child('confirms').child('for').set(itemObj?.value['confirms']['for'] + 1);
      newItem.child('last_confirm_time').set(nowTime);
    }
  }

  static Future<void> subtractPoint(LatLng pointCoordinates, MarkerType markerType, List<String> centers) async {
    var pointType = EnumMethods.enumToString(markerType);
    var markerId = (pointCoordinates.latitude * 1000).truncate().toString() + '_' + (pointCoordinates.longitude * 1000).truncate().toString();
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
        continue;
      }
      for (var markerType in MarkerType.values) {
        var typedMap = radiusSnapshot?.value[EnumMethods.enumToString(markerType)] ?? {};
        for (var point in typedMap?.values ?? []) {
          var pointCoordinates = LatLng(point['coordX'] * 1.0, point['coordY'] * 1.0);
          var confirmsForNumber = point['confirms']['for'] ?? 0;
          var confirmsAgainstNumber = point['confirms']['against'] ?? 0;
          var lastTimeConfirmation = point['last_confirm_time'];
          var descriptionText = point['descriptionText'];
          var newPoint = MarkerInfo(
              markerType: markerType,
              coordinates: pointCoordinates,
              confirmsFor: confirmsForNumber,
              confirmsAgainst: confirmsAgainstNumber,
              lastTimeConfirmation: lastTimeConfirmation,
              descriptionText: descriptionText ?? '');
          markers.add(newPoint);
        }
      }
    }
    return markers;
  }

  static plusConfirmsFor(MarkerInfo markerInfo, {int addValue = 1}) async {
    Set<String> centers = markerInfo.getCentersSet();
    // var markerId = (markerInfo.coordinates.latitude * 1000).truncate().toString() + (markerInfo.coordinates.longitude * 1000).truncate().toString();
    // var markerId = (markerInfo.coordinates.latitude * 1000).truncate().toString() + '_' + (markerInfo.coordinates.longitude * 1000).truncate().toString();
    var markerId = markerInfo.dbMarkerId();
    DatabaseReference itemConfirmsDatabaseReference = FirebaseDatabase.instance
        .reference()
        .child(markerInfo.dbCenter())
        .child(EnumMethods.enumToString(markerInfo.markerType))
        .child(markerId)
        .child('confirms')
        .child('for');
    var confirms = await itemConfirmsDatabaseReference.once();
    itemConfirmsDatabaseReference.set((confirms?.value ?? 0) + addValue);
    // for (var center in centers) {
    //   DatabaseReference itemConfirmsDatabaseReference = FirebaseDatabase.instance
    //       .reference()
    //       .child(center)
    //       .child(EnumMethods.enumToString(markerInfo.markerType))
    //       .child(markerId)
    //       .child('confirms')
    //       .child('for');
    //   var confirms = await itemConfirmsDatabaseReference.once();
    //   itemConfirmsDatabaseReference.set((confirms?.value ?? 0) + addValue);
    // }
  }

  static plusConfirmsAgainst(MarkerInfo markerInfo, {int addValue = 1}) async {
    Set<String> centers = markerInfo.getCentersSet();
    // var markerId = (markerInfo.coordinates.latitude * 1000).truncate().toString() + (markerInfo.coordinates.longitude * 1000).truncate().toString();
    // var markerId = (markerInfo.coordinates.latitude * 1000).truncate().toString() + '_' + (markerInfo.coordinates.longitude * 1000).truncate().toString();
    var markerId = markerInfo.dbMarkerId();
    DatabaseReference itemConfirmsDatabaseReference = FirebaseDatabase.instance
        .reference()
        .child(markerInfo.dbCenter())
        .child(EnumMethods.enumToString(markerInfo.markerType))
        .child(markerId)
        .child('confirms')
        .child('against');
    var confirms = await itemConfirmsDatabaseReference.once();
    itemConfirmsDatabaseReference.set((confirms?.value ?? 0) + addValue);
    // for (var center in centers) {
    //   DatabaseReference itemConfirmsDatabaseReference = FirebaseDatabase.instance
    //       .reference()
    //       .child(center)
    //       .child(EnumMethods.enumToString(markerInfo.markerType))
    //       .child(markerId)
    //       .child('confirms')
    //       .child('against');
    //   var confirms = await itemConfirmsDatabaseReference.once();
    //   itemConfirmsDatabaseReference.set((confirms?.value ?? 0) + addValue);
    // }
  }

  static addDescriptionText(MarkerInfo markerInfo, String descriptionText) {
    DatabaseReference descriptionTextDatabaseReference = FirebaseDatabase.instance
        .reference()
        .child(markerInfo.dbCenter())
        .child(EnumMethods.enumToString(markerInfo.markerType))
        .child(markerInfo.dbMarkerId())
        .child('descriptionText');
    descriptionTextDatabaseReference.set(descriptionText);
  }

  static Future<bool> updateUserMarkers() async {
    for (var markerKey in globals.userMarkers.keys) {
      var markerInfo = globals.userMarkers[markerKey];
      DatabaseReference descriptionTextDatabaseReference = FirebaseDatabase.instance
          .reference()
          .child(markerInfo.dbCenter())
          .child(EnumMethods.enumToString(markerInfo.markerType))
          .child(markerInfo.dbMarkerId());
      var newMarkerInfo = (await descriptionTextDatabaseReference.once()).value;
      // var pointCoordinates = LatLng(newMarkerInfo['coordX'] * 1.0, newMarkerInfo['coordY'] * 1.0);
      var confirmsForNumber = newMarkerInfo['confirms']['for'] ?? 0;
      var confirmsAgainstNumber = newMarkerInfo['confirms']['against'] ?? 0;
      var lastTimeConfirmation = newMarkerInfo['last_confirm_time'];
      var descriptionText = newMarkerInfo['descriptionText'];
      globals.userMarkers[markerKey].confirmsFor = confirmsForNumber;
      globals.userMarkers[markerKey].confirmsAgainst = confirmsAgainstNumber;
      globals.userMarkers[markerKey].lastTimeConfirmation = lastTimeConfirmation;
      globals.userMarkers[markerKey].descriptionText = descriptionText;
    }
    await FileOperations.writeUserMarkers();
    return true;
  }

  static Future<void> deletePoint(MarkerInfo markerInfo) async {
    var dbMarker = FirebaseDatabase.instance
        .reference()
        .child(markerInfo.dbCenter())
        .child(EnumMethods.enumToString(markerInfo.markerType))
        .child(markerInfo.dbMarkerId());
    dbMarker.remove();
  }
}
