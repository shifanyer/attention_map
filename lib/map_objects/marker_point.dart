import 'package:attention_map/enums/marker_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInfo {
  final MarkerType markerType;
  LatLng coordinates;
  int confirms;
  int lastTimeConfirmation;

  MarkerInfo({@required this.markerType, @required this.coordinates, @required this.confirms, @required this.lastTimeConfirmation});

  MarkerId getMarkerId() {
    return MarkerId(this.coordinates.latitude.toString() + coordinates.longitude.toString());
  }

  @override
  String toString() {
    return 'markerType: ${markerType}, coordinates: ${coordinates}, confirms: ${confirms}, lastTimeConfirmation: ${lastTimeConfirmation}';
  }

}