import 'package:attention_map/enums/marker_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInfo {
  final MarkerType markerType;
  LatLng coordinates;
  int confirmsFor;
  int confirmsAgainst;
  int lastTimeConfirmation;

  MarkerInfo({@required this.markerType, @required this.coordinates, @required this.confirmsFor, @required this.confirmsAgainst, @required this.lastTimeConfirmation});

  MarkerId getMarkerId() {
    return MarkerId(this.coordinates.latitude.toString() + coordinates.longitude.toString());
  }

  @override
  String toString() {
    return 'markerType: ${markerType}, coordinates: ${coordinates}, for: ${confirmsFor}, against: ${confirmsAgainst}, lastTimeConfirmation: ${lastTimeConfirmation}';
  }

}