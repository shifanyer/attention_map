library attention_map.globals;

import 'package:attention_map/map_objects/marker_point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Map<MarkerId, int> userDecisions;
double bottomHeight = 70.0;
GoogleMapController googleMapController;
Map<String, MarkerInfo> userMarkers;
bool isDarkTheme = false;
bool isNotificationsOn = true;