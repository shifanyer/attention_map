import 'dart:async';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/map/map_helper.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'bottom_bar.dart';
import 'enums/marker_type.dart';
import 'local_db/write_in_file.dart';
import 'map/main_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Map<MarkerType, BitmapDescriptor>> loadMarkers() async {
    Map<MarkerType, BitmapDescriptor> customMarkers = {};
    customMarkers[MarkerType.camera] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/camera_marker.png');
    customMarkers[MarkerType.dps] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/dps_marker.png');
    customMarkers[MarkerType.monument] =
        await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/monument_marker.png');
    customMarkers[MarkerType.dtp] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/dtp_marker.png');
    customMarkers[MarkerType.danger] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/danger_marker.png');
    customMarkers[MarkerType.help] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/help_marker.png');
    customMarkers[MarkerType.other] =
        await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/other_marker.png');
    return customMarkers;
  }

  Map<MarkerType, BitmapDescriptor> markers;
  List<MarkerInfo> markersList;

  @override
  Widget build(BuildContext context) {
    var futures = Future.wait([
      Firebase.initializeApp(),
      DbMainMethods.downloadPointsList(['0']).then((value) => markersList = value),
      loadMarkers().then((value) => markers = value),
      FileOperations.readUserDecisions(),
      FileOperations.readUserMarkers(),
      FileOperations.readUserData(),
    ]);
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: FutureBuilder(
        future: futures,
          builder: (context, futuresSnapshot) {
            if (futuresSnapshot.connectionState != ConnectionState.waiting) {
              return BottomBar(
                markers: markers,
                markersList: markersList,
              );
            } else {
              return Container();
            }
          }
      ),
      /*
      home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return FutureBuilder(
                  future: DbMainMethods.downloadPointsList(['0']),
                  builder: (context, pointsListSnapshot) {
                    if (pointsListSnapshot.hasData) {
                      return FutureBuilder(
                          future: loadMarkers(),
                          builder: (context, loadMarkersSnapshot) {
                            if (loadMarkersSnapshot.hasData)
                              return FutureBuilder(
                                  future: FileOperations.readUserDecisions(),
                                  builder: (context, userDecisionsSnapshot) {
                                    if (userDecisionsSnapshot.hasData) {
                                      return FutureBuilder(
                                          future: FileOperations.readUserMarkers(),
                                          builder: (context, userMarkersSnapshot) {
                                            if (userMarkersSnapshot.hasData) {
                                              return BottomBar(
                                                markers: loadMarkersSnapshot.data,
                                                markersList: pointsListSnapshot.data,
                                              );
                                            } else {
                                              return Container();
                                            }
                                          });
                                    } else {
                                      return Container();
                                    }
                                  });
                            else
                              return Container();
                          });
                    } else {
                      return Container();
                    }
                  });
            else {
              return Container();
            }
          }),
      */
    );
  }
}
