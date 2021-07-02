import 'dart:async';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'map/main_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return FutureBuilder(
                  future: DbMainMethods.downloadPointsList(['-555605']),
                  builder: (context, pointsListSnapshot) {
                    if (snapshot.hasData) {
                      return MainMap(
                        markersList: pointsListSnapshot.data,
                      );
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
