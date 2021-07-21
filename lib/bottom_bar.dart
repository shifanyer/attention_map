import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'enums/marker_type.dart';
import 'map/main_map.dart';
import 'map_objects/marker_point.dart';
import 'my_markers/my_markers.dart';
import 'global/globals.dart' as globals;
import 'settings/settings.dart';

/// This is the stateful widget that the main application instantiates.
class BottomBar extends StatefulWidget {
  final Map<MarkerType, BitmapDescriptor> markers;
  final List<MarkerInfo> markersList;

  const BottomBar({Key key, @required this.markersList, @required this.markers}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _BottomBarState extends State<BottomBar> {
  int _selectedIndex;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text(
  //     'Index 0: Home',
  //     style: optionStyle,
  //   ),
  //   MainMap(
  //   markersList: widget.markersList,
  //   ),
  //   Text(
  //     'Index 2: School',
  //     style: optionStyle,
  //   ),
  // ];

  LatLng startCameraPosition = LatLng(59.666999, 51.58008);
  List<Widget> widgetOptions;

  @override
  void initState() {
    _selectedIndex = 1;
    widgetOptions = <Widget>[
      MyMarkers(),
      MainMap(
        startCameraPosition: startCameraPosition,
        customMarkers: widget.markers,
        markersList: widget.markersList,
      ),
      SettingsPage(),
      // Text(
      //   'Index 2: School',
      //   style: optionStyle,
      // ),
    ];
    // startCameraPosition = ;
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        globals.isMapOpened = true;
      }
      else {
        globals.googleMapController = null;
        globals.isMapOpened = false;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SizedBox(
        height: globals.bottomHeight,
        child: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.assistant_photo),
              label: 'Markers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_pin),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
