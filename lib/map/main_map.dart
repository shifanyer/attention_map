import 'dart:async';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bottom_choose_list.dart';

class MainMap extends StatefulWidget {
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  Map<MarkerId, Marker> markers = {};
  LocationData _currentPosition;
  Map<MarkerType, BitmapDescriptor> customMarkers = {};
  String _address, _dateTime;
  GoogleMapController mapController;

  // Marker marker;
  Location location = Location();

  GoogleMapController _controller;
  LatLng initialCameraPosition = LatLng(0.5937, 0.9629);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
  }

  // создание меток
  Future<bool> customMarkersMaker() async {
    customMarkers[MarkerType.camera] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/camera_marker.png');
    customMarkers[MarkerType.dps] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/DPS_marker.png');
    customMarkers[MarkerType.monument] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/monument_marker.png');
    customMarkers[MarkerType.other] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png');
    return true;
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    // _controller = _controller;
    location.onLocationChanged.listen((l) {
      if (_controller != null)
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 15),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: customMarkersMaker(),
        builder: (context, customMarkersMakerSnapshot) {
          return Scaffold(
            body: (customMarkersMakerSnapshot?.data == true)
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                    ),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SafeArea(
                      child: Container(
                        color: Colors.blueGrey.withOpacity(.8),
                        child: Center(
                          child:
                          /*
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: 15),
                              mapType: MapType.normal,
                              onMapCreated: _onMapCreated,
                              myLocationEnabled: true,
                              markers: markers.values.toSet(),
                            ),
                          ),
                          */


                          Column(
                            children: [
                              //карта
                              Container(
                                height: MediaQuery.of(context).size.height * 0.8,
                                width: MediaQuery.of(context).size.width,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: 15),
                                  mapType: MapType.normal,
                                  onMapCreated: _onMapCreated,
                                  myLocationEnabled: true,
                                  markers: markers.values.toSet(),
                                ),
                              ),


                              SizedBox(
                                height: 3,
                              ),
                              if (_dateTime != null)
                                Text(
                                  "Date/Time: $_dateTime",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              SizedBox(
                                height: 3,
                              ),
                              if (_currentPosition != null)
                                Text(
                                  "Latitude: ${_currentPosition.latitude}, Longitude: ${_currentPosition.longitude}",
                                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              SizedBox(
                                height: 3,
                              ),
                              if (_address != null)
                                Text(
                                  "Address: $_address",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              SizedBox(
                                height: 3,
                              ),

                            ],
                          ),

                        ),
                      ),
                    ),
                  )
                : Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator())),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await addMarker();
              },
            ),
          );
        });
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    initialCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        initialCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        _getAddress(_currentPosition.latitude, _currentPosition.longitude).then((value) {
          setState(() {
            // _address = "${value.first.addressLine}";
            _address = "value.first.addressLine";
          });
        });
      });
    });
  }

  // определение адреса
  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    // List<Address> add = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // return add;
    return null;
  }

  // создание метки
  Future<void> addMarker() async {
    var pointType = '';
    // выбор типа точки
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Builder(
          builder: (BuildContext context) {
            return SelectPointType(
              pointType: (String value) {
                pointType = value;
              },
            );
          },
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      isScrollControlled: false,
      isDismissible: true,
    );

    var markerType = MarkerType.noType;
    if (pointType == 'Камера') {
      markerType = MarkerType.camera;
    }
    if (pointType == 'Пост ДПС') {
      markerType = MarkerType.dps;
    }
    if (pointType == 'Достопримечательность') {
      markerType = MarkerType.monument;
    }
    if (pointType == 'Другое') {
      markerType = MarkerType.other;
    }
    // if (pointType == 'Опасный участок дороги') {
    //   markerType = 'danger';
    // }

    if (markerType == MarkerType.noType){
      return;
    }
    var latLon = await location.getLocation();
    var markerCoordinates = LatLng(latLon.latitude, latLon.longitude);
    var markerIdVal = markerIdGen(markerCoordinates);
    final MarkerId markerId = MarkerId(markerIdVal);
    // creating a new MARKER
    final Marker marker = Marker(
      icon: customMarkers[markerType],
      markerId: markerId,
      position: markerCoordinates,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
      },
    );

    DbMainMethods.uploadPoint(markerCoordinates, markerType, ['-555605']);
    var dbMarkers = await DbMainMethods.downloadPoints(['-555605']);

    setState(() {
      for (var dbMarker in dbMarkers){
        var dbMarkerId = dbMarker.getMarkerId();
        markers[dbMarkerId] = Marker(
          icon: customMarkers[dbMarker.markerType],
          markerId: dbMarkerId,
          position: dbMarker.coordinates,
          infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
          onTap: () {
          },
        );
      }
      // adding a new marker to map
      // markers[markerId] = marker;
    });
  }

  //создание ID метки
  String markerIdGen(LatLng coordinates) {
    return coordinates.latitude.toString() + coordinates.longitude.toString();
  }
}
