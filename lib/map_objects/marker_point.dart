import 'dart:math';

import 'package:attention_map/enums/marker_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInfo {
  final MarkerType markerType;
  LatLng coordinates;
  int confirmsFor;
  int confirmsAgainst;
  int lastTimeConfirmation;
  String descriptionText;

  MarkerInfo(
      {@required this.markerType,
      @required this.coordinates,
      @required this.confirmsFor,
      @required this.confirmsAgainst,
      @required this.lastTimeConfirmation,
      this.descriptionText = ''});

  MarkerId getMarkerId() {
    return MarkerId(this.coordinates.latitude.toString() + '_' + coordinates.longitude.toString());
  }

  double getPercentage() {
    return ((confirmsFor ?? 0) / ((confirmsFor ?? 0) + (confirmsAgainst ?? 0))) * 100;
  }

  int getHumanReadablePercentage() {
    return (getPercentage()).truncate();
  }

  Set<String> getCentersSet() {
    LatLng currentLocation = coordinates;
    var lat10 = (currentLocation.latitude * 10).ceil();
    var lon10 = (currentLocation.longitude * 10).ceil();

    var lat10div5 = (lat10 ~/ 5) * 5;
    var lon10div5 = (lon10 ~/ 5) * 5;

    var centersList = [
      LatLng(lat10div5 / 10.0 - 0.5, lon10div5 / 10.0 - 0.5),
      LatLng(lat10div5 / 10.0 - 0.5, lon10div5 / 10.0 - 0.0),
      LatLng(lat10div5 / 10.0 - 0.5, lon10div5 / 10.0 + 0.5),
      LatLng(lat10div5 / 10.0 - 0.0, lon10div5 / 10.0 - 0.5),
      LatLng(lat10div5 / 10.0 - 0.0, lon10div5 / 10.0 - 0.0),
      LatLng(lat10div5 / 10.0 - 0.0, lon10div5 / 10.0 + 0.5),
      LatLng(lat10div5 / 10.0 + 0.5, lon10div5 / 10.0 - 0.5),
      LatLng(lat10div5 / 10.0 + 0.5, lon10div5 / 10.0 - 0.0),
      LatLng(lat10div5 / 10.0 + 0.5, lon10div5 / 10.0 + 0.5)
    ];

    var resSet = <String>{};

    for (var center in centersList) {
      if (((center.latitude - currentLocation.latitude).abs() <= 0.51) && ((center.longitude - currentLocation.longitude).abs() <= 0.51)) {
        resSet.add(((center.latitude * 10).toString()).split('.').first + '_' + ((center.longitude * 10).toString()).split('.').first);
      }
    }

    return resSet;
  }

  String dbCenter() {
    var centersSet = getCentersSet();
    var minDist = -1.0;
    var pointCenter = LatLng(0.0, 0.0);
    for (var center in centersSet) {
      var radiusCenter = LatLng(int.parse(center.split('_').first) / 10, int.parse(center.split('_').last) / 10);
      var dist = pow((radiusCenter.latitude - coordinates.latitude), 2) + pow((radiusCenter.longitude - coordinates.longitude), 2);
      if ((minDist == -1.0) || (dist < minDist)) {
        minDist = dist;
        pointCenter = radiusCenter;
      }
    }

    var pointCenterString = (pointCenter.latitude * 10).truncate().toString() + '_' + (pointCenter.longitude * 10).truncate().toString();
    return pointCenterString;
  }

  String dbMarkerId() {
    return (coordinates.latitude * 1000).truncate().toString() + '_' + (coordinates.longitude * 1000).truncate().toString();
  }

  @override
  String toString() {
    return 'markerType: ${markerType}, coordinates: ${coordinates}, for: ${confirmsFor}, against: ${confirmsAgainst}, lastTimeConfirmation: ${lastTimeConfirmation}';
  }

  MarkerInfo.fromJson(Map<String, dynamic> json)
      : markerType = MarkerType.values.firstWhere((e) => e.toString() == json['markerType']),
        coordinates = LatLng(json['coordX'], json['coordY']),
        confirmsFor = json['confirmsFor'],
        confirmsAgainst = json['confirmsAgainst'],
        lastTimeConfirmation = json['lastTimeConfirmation'],
        descriptionText = json['descriptionText'];

  Map<String, dynamic> toJson() => {
        'markerType': markerType.toString(),
        'coordX': coordinates.latitude,
        'coordY': coordinates.longitude,
        'confirmsFor': confirmsFor,
        'confirmsAgainst': confirmsAgainst,
        'lastTimeConfirmation': lastTimeConfirmation,
        'descriptionText': descriptionText,
      };
}
