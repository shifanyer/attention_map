import 'dart:async';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bottom_choose_list.dart';

class MainMap extends StatefulWidget {
  final LatLng startCameraPosition;
  final List<MarkerInfo> markersList;

  const MainMap({Key key, this.startCameraPosition, @required this.markersList}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  List<Marker> markers = [];
  LocationData _currentPosition;
  Map<MarkerType, BitmapDescriptor> customMarkers = {};
  String _address, _dateTime;
  GoogleMapController mapController;
  var centersSet = <String>{};
  bool firstLoad = true;
  List<MarkerInfo> dbMarkers = [];
  double zoomValue = 17.0;

  // Marker marker;
  Location location = Location();

  GoogleMapController _controller;
  LatLng initialCameraPosition = LatLng(0.5937, 0.9629);

  @override
  void initState() {
    if (widget?.startCameraPosition != null) {
      initialCameraPosition = widget.startCameraPosition;
    }
    // TODO: implement initState
    getLoc();
    super.initState();
  }

  // создание меток
  Future<bool> customMarkersMaker(List<MarkerInfo> markersList) async {
    if (firstLoad) {
      // заготовка стандартных маркеров
      customMarkers[MarkerType.camera] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/camera_marker.png');
      customMarkers[MarkerType.dps] = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/DPS_marker.png');
      customMarkers[MarkerType.monument] =
      await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/monument_marker.png');
      customMarkers[MarkerType.other] =
      await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png');

      //ДОБАВЛЕНИЕ ТОЧЕК В map точек
      dbMarkers = markersList;
      for (var dbMarker in markersList) {
        var dbMarkerId = dbMarker.getMarkerId();
        markers.add(Marker(
          icon: customMarkers[dbMarker.markerType],
          markerId: dbMarkerId,
          position: dbMarker.coordinates,
          infoWindow: InfoWindow(title: dbMarkerId.value, snippet: '*'),
          onTap: () {},
        ));
      }
      firstLoad = false;
    }
    return true;
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    location.onLocationChanged.listen((l) {
      if (_controller != null) {
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: zoomValue),
          ),
        );
        /*
        Set<String> updatedCentersSet = getCentersSet(l);
        if (!centersSet.containsAll(updatedCentersSet)) {
          centersSet = updatedCentersSet;
          updateMarkers();
        }

         */
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: customMarkersMaker(widget.markersList),
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
                          child: Column(
                            children: [
                              //карта
                              Container(
                                height: MediaQuery.of(context).size.height * 0.8,
                                width: MediaQuery.of(context).size.width,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: zoomValue),
                                  mapType: MapType.normal,
                                  onMapCreated: _onMapCreated,
                                  myLocationEnabled: true,
                                  markers: markers.toSet(),
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
                await addMarker(initialCameraPosition);
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
    location.onLocationChanged.listen((LocationData currentLocation) async {
      Set<String> updatedCentersSet = getCentersSet(currentLocation);
      print(centersSet);
      print(updatedCentersSet);
      if (!centersSet.containsAll(updatedCentersSet)) {
        centersSet = updatedCentersSet;
        await updateMarkers();
      }
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(currentLocation.latitude, currentLocation.longitude), zoom: zoomValue),
        ),
      );
      _currentPosition = currentLocation;
      initialCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);
      /*
      setState(() {
        _currentPosition = currentLocation;
        initialCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);


        /*
        _getAddress(_currentPosition.latitude, _currentPosition.longitude).then((value) {
          setState(() {
            // _address = "${value.first.addressLine}";
            _address = "value.first.addressLine";
          });
        });
        */
      });
      */
    });
  }

  Set<String> getCentersSet(LocationData currentLocation) {
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
        resSet.add(((center.latitude * 10).toString()).split('.').first + ((center.longitude * 10).toString()).split('.').first);
      }
    }

    return resSet;
  }

  // определение адреса
  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    // List<Address> add = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // return add;
    return null;
  }

  // загрузка маркеров из db
  Future<void> updateMarkers() async {
    dbMarkers = await DbMainMethods.downloadPointsList(centersSet.toList());

    markers = [];
    for (var dbMarker in dbMarkers) {
      var dbMarkerId = dbMarker.getMarkerId();
      markers.add(Marker(
        icon: customMarkers[dbMarker.markerType],
        markerId: dbMarkerId,
        position: dbMarker.coordinates,
        infoWindow: InfoWindow(title: dbMarkerId.value, snippet: '*'),
        onTap: () {},
      ));
    }

    setState(() {
      // adding a new marker to map
      // markers[markerId] = marker;
    });
  }

  // создание метки
  Future<void> addMarker(LatLng location) async {
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

    if (markerType == MarkerType.noType) {
      return;
    }
    // var latLon = await location.getLocation();
    var latLon = location;
    var markerCoordinates = LatLng(latLon.latitude, latLon.longitude);

    /*
    for (var marker in dbMarkers) {
      if (((marker.coordinates.latitude - markerCoordinates.latitude).abs() <= 0.00001) && ((marker.coordinates.longitude - markerCoordinates.longitude).abs() <= 0.00001)){

        break;
      }
    }
     */

    setState(() async {
      await DbMainMethods.uploadPoint(markerCoordinates, markerType, centersSet.toList());
      await updateMarkers();
    });
  }

  //создание ID метки
  String markerIdGen(LatLng coordinates) {
    return coordinates.latitude.toString() + coordinates.longitude.toString();
  }
}
