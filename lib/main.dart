import 'dart:async';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/map/map_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'bottom_bar.dart';
import 'enums/marker_type.dart';
import 'map/main_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Map<MarkerType, BitmapDescriptor>> loadMarkers() async {
    Map<MarkerType, BitmapDescriptor> customMarkers = {};
    customMarkers[MarkerType.camera] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/camera_marker.png');
    customMarkers[MarkerType.dps] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/DPS_marker.png');
    customMarkers[MarkerType.monument] =
        await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/monument_marker.png');
    customMarkers[MarkerType.dtp] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/dtp_marker.png');
    customMarkers[MarkerType.danger] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/danger_marker.png');
    customMarkers[MarkerType.help] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/help_marker.png');
    customMarkers[MarkerType.other] =
        await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png');
    return customMarkers;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
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
                          builder: (context, snapshot) {
                            if (snapshot.hasData)
                              return BottomBar(
                                markers: snapshot.data,
                                markersList: pointsListSnapshot.data,
                              );
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
    );
  }
}
