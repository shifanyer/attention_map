import 'dart:async';
import 'dart:math';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/enums/enumMethods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/map_objects/marker_scale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bottom_choose_list.dart';
import 'map_helper.dart';

class MainMap extends StatefulWidget {
  LatLng startCameraPosition;
  final List<MarkerInfo> markersList;
  final Map<MarkerType, BitmapDescriptor> customMarkers;
  GoogleMapController googleMapController;

  MainMap({Key key, this.startCameraPosition, @required this.markersList, @required this.customMarkers, @required this.googleMapController})
      : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with MapHelper {
  List<Marker> markers = [];
  LocationData _currentPosition;
  String _address, _dateTime;
  GoogleMapController mapController;
  var centersSet = <String>{};
  bool firstLoad = true;
  List<MarkerInfo> dbMarkers = [];
  Map<MarkerId, int> userDecision = {};
  double zoomValue = 17.0;
  bool followLocation = true;
  bool isAutoCameraMove = true;
  MarkerInfo changeMarkerInfo;
  bool ifChangeMarkerInfo = false;
  LatLng prevDot;

  // Marker marker;
  Location location = Location();

  // LatLng initialCameraPosition = LatLng(59.666999, 51.58008);
  LatLng initialCameraPosition;

  @override
  void initState() {
    customMarkers = widget.customMarkers;
    initialCameraPosition = widget.startCameraPosition;
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
      //ДОБАВЛЕНИЕ ТОЧЕК В map точек
      dbMarkers = markersList;
      for (var dbMarker in markersList) {
        var dbMarkerId = dbMarker.getMarkerId();
        markers.add(Marker(
          icon: customMarkers[dbMarker.markerType],
          markerId: dbMarkerId,
          position: dbMarker.coordinates,
          infoWindow: InfoWindow(title: EnumMethods.getDescription(dbMarker.markerType), snippet: 'Подтвердили: ${dbMarker.confirmsFor}'),
          onTap: () {},
        ));
      }
      firstLoad = false;
    }
    return true;
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    widget.googleMapController = _cntlr;
    if (followLocation) {
      isAutoCameraMove = true;
      widget.googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude), zoom: zoomValue, tilt: 15.0, bearing: 25),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget.startCameraPosition: ${widget.startCameraPosition}');
    if (firstLoad) {
      //ДОБАВЛЕНИЕ ТОЧЕК В map точек
      dbMarkers = widget.markersList;
      for (var dbMarker in widget.markersList) {
        var dbMarkerId = dbMarker.getMarkerId();
        markers.add(Marker(
          icon: customMarkers[dbMarker.markerType],
          markerId: dbMarkerId,
          position: dbMarker.coordinates,
          infoWindow: InfoWindow(title: EnumMethods.getDescription(dbMarker.markerType), snippet: 'Подтвердили: ${dbMarker.confirmsFor}'),
          onTap: () {},
        ));
      }
      firstLoad = false;
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.cyanAccent,
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: [
                  //карта
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: zoomValue),
                      mapType: MapType.normal,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      markers: markers.toSet(),
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      trafficEnabled: true,
                      onTap: (_) {
                        setState(() {
                          ifChangeMarkerInfo = false;
                        });
                      },
                      onCameraMoveStarted: () {
                        setState(() {
                          if (!isAutoCameraMove) followLocation = false;
                        });
                      },
                      onCameraIdle: () {
                        setState(() {
                          if (isAutoCameraMove) {
                            followLocation = true;
                          }
                          isAutoCameraMove = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.15 - 30 * 2.5) / 2,
                  ),
                  (ifChangeMarkerInfo)
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: MarkerScale(
                            markerInfo: changeMarkerInfo,
                            userDecision: userDecision,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: () {
                                followLocation = !followLocation;
                                if (followLocation) {
                                  isAutoCameraMove = true;
                                  widget.googleMapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                          target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude),
                                          zoom: zoomValue,
                                          tilt: 15.0,
                                          bearing: 25),
                                    ),
                                  );
                                }
                                setState(() {});
                              },
                              child: Icon(Icons.adjust, color: followLocation ? Colors.black : Colors.white70),
                            ),
                            FloatingActionButton(
                              onPressed: () async {
                                await addMarker(initialCameraPosition);
                              },
                              child: Icon(
                                Icons.not_listed_location,
                                size: 30,
                              ),
                            )
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      /*
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (ifChangeMarkerInfo)
                    ? MarkerScale(
                        markerInfo: changeMarkerInfo,
                        userDecision: userDecision,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (ifChangeMarkerInfo)
                              ? confirmMarkerFAB(changeMarkerInfo)
                              : FloatingActionButton(
                                  onPressed: () {
                                    followLocation = !followLocation;
                                    if (followLocation) {
                                      isAutoCameraMove = true;
                                      _controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude),
                                              zoom: zoomValue,
                                              tilt: 15.0,
                                              bearing: 25),
                                        ),
                                      );
                                    }
                                    setState(() {});
                                  },
                                  child: Icon(Icons.adjust, color: followLocation ? Colors.black : Colors.white70),
                                ),
                          (ifChangeMarkerInfo)
                              ? subtractMarkerFAB(changeMarkerInfo)
                              : FloatingActionButton(
                                  onPressed: () async {
                                    await addMarker(initialCameraPosition);
                                  },
                                  child: Icon(
                                    Icons.not_listed_location,
                                    size: 30,
                                  ),
                                )
                        ],
                      ),

              )
              */
    );
    /*
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
                          color: Colors.white,
                          child: Center(
                            child: Column(
                              children: [
                                //карта
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.75,
                                  width: MediaQuery.of(context).size.width,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: zoomValue),
                                    mapType: MapType.normal,
                                    onMapCreated: _onMapCreated,
                                    myLocationEnabled: true,
                                    markers: markers.toSet(),
                                    mapToolbarEnabled: false,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    trafficEnabled: true,
                                    onTap: (_) {
                                      setState(() {
                                        ifChangeMarkerInfo = false;
                                      });
                                    },
                                    onCameraMoveStarted: () {
                                      setState(() {
                                        if (!isAutoCameraMove) followLocation = false;
                                      });
                                    },
                                    onCameraIdle: () {
                                      setState(() {
                                        if (isAutoCameraMove) {
                                          followLocation = true;
                                        }
                                        isAutoCameraMove = false;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: (MediaQuery.of(context).size.height * 0.15 - 30 * 2.5) / 2,
                                ),
                                (ifChangeMarkerInfo) ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: MarkerScale(
                                    markerInfo: changeMarkerInfo,
                                    userDecision: userDecision,
                                  ),
                                ) : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      onPressed: () {
                                        followLocation = !followLocation;
                                        if (followLocation) {
                                          isAutoCameraMove = true;
                                          _controller.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude),
                                                  zoom: zoomValue,
                                                  tilt: 15.0,
                                                  bearing: 25),
                                            ),
                                          );
                                        }
                                        setState(() {});
                                      },
                                      child: Icon(Icons.adjust, color: followLocation ? Colors.black : Colors.white70),
                                    ),
                                    FloatingActionButton(
                                      onPressed: () async {
                                        await addMarker(initialCameraPosition);
                                      },
                                      child: Icon(
                                        Icons.not_listed_location,
                                        size: 30,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator())),
              /*
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (ifChangeMarkerInfo)
                    ? MarkerScale(
                        markerInfo: changeMarkerInfo,
                        userDecision: userDecision,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          (ifChangeMarkerInfo)
                              ? confirmMarkerFAB(changeMarkerInfo)
                              : FloatingActionButton(
                                  onPressed: () {
                                    followLocation = !followLocation;
                                    if (followLocation) {
                                      isAutoCameraMove = true;
                                      _controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude),
                                              zoom: zoomValue,
                                              tilt: 15.0,
                                              bearing: 25),
                                        ),
                                      );
                                    }
                                    setState(() {});
                                  },
                                  child: Icon(Icons.adjust, color: followLocation ? Colors.black : Colors.white70),
                                ),
                          (ifChangeMarkerInfo)
                              ? subtractMarkerFAB(changeMarkerInfo)
                              : FloatingActionButton(
                                  onPressed: () async {
                                    await addMarker(initialCameraPosition);
                                  },
                                  child: Icon(
                                    Icons.not_listed_location,
                                    size: 30,
                                  ),
                                )
                        ],
                      ),

              )
              */
              );
        });

     */
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
    widget.startCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);

    location.onLocationChanged.listen((LocationData currentLocation) async {
      prevDot = initialCameraPosition;
      Set<String> updatedCentersSet = getCentersSet(currentLocation);
      if (!centersSet.containsAll(updatedCentersSet)) {
        centersSet = updatedCentersSet;
        await updateMarkers();
      }

      // Zoom при перемещении обратно к геопозиции не меняется, если отдалиться или приблизиться
      if (widget.googleMapController != null) {
        zoomValue = await widget.googleMapController.getZoomLevel();
      }
      if (followLocation) {
        var bearing = calculateBearing(prevDot, LatLng(_currentPosition.latitude, _currentPosition.longitude));
        print(bearing);
        isAutoCameraMove = true;
        widget.googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(currentLocation.latitude, currentLocation.longitude), zoom: zoomValue, tilt: 15.0, bearing: 25),
          ),
        );
      }

      _currentPosition = currentLocation;
      initialCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);
      widget.startCameraPosition = LatLng(_currentPosition.latitude, _currentPosition.longitude);
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
        visible: dbMarker.confirmsFor > 0,
        infoWindow: InfoWindow(title: EnumMethods.getDescription(dbMarker.markerType), snippet: 'Подтвердили: ${dbMarker.confirmsFor}'),
        onTap: () async {
          if (followLocation) {
            isAutoCameraMove = true;
            widget.googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude), zoom: zoomValue, tilt: 15.0, bearing: 25),
              ),
            );
          }
          setState(() {
            if (!ifChangeMarkerInfo) {
              changeMarkerInfo = dbMarker;
              ifChangeMarkerInfo = true;
            } else {
              if (ifChangeMarkerInfo && (changeMarkerInfo == dbMarker)) {
                ifChangeMarkerInfo = false;
                widget.googleMapController.hideMarkerInfoWindow(dbMarker.getMarkerId());
              } else {
                changeMarkerInfo = dbMarker;
              }
            }
          });
        },
        // consumeTapEvents: true,
      ));
    }

    setState(() {});
  }

  // создание метки
  Future<void> addMarker(LatLng location) async {
    var pointType = MarkerType.noType;
    // выбор типа точки
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Builder(
          builder: (BuildContext context) {
            return SelectPointType(
              pointType: (MarkerType value) {
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

    var markerType = pointType;
    if (markerType == MarkerType.noType) {
      return;
    }
    // var latLon = await location.getLocation();
    var latLon = location;
    var markerCoordinates = LatLng(latLon.latitude, latLon.longitude);

    await DbMainMethods.uploadPoint(markerCoordinates, markerType, centersSet.toList());
    await updateMarkers();
    setState(() {});
  }

  // подтверждение метки
  Future<void> confirmMarker(MarkerInfo markerInfo) async {
    // var latLon = await location.getLocation();
    var latLon = markerInfo.coordinates;
    var markerCoordinates = LatLng(latLon.latitude, latLon.longitude);

    Fluttertoast.showToast(
        msg: "Число подтверждений увеличено",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    widget.googleMapController.hideMarkerInfoWindow(markerInfo.getMarkerId());
    setState(() {
      ifChangeMarkerInfo = false;
    });
    await DbMainMethods.uploadPoint(markerCoordinates, markerInfo.markerType, centersSet.toList());
    await updateMarkers();
    // setState(() {});
  }

  // убавить подтверждения метки
  Future<void> subtractMarker(MarkerInfo markerInfo) async {
    // var latLon = await location.getLocation();
    var latLon = markerInfo.coordinates;
    var markerCoordinates = LatLng(latLon.latitude, latLon.longitude);

    Fluttertoast.showToast(
        msg: "Число подтверждений уменьшено",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    setState(() {
      ifChangeMarkerInfo = false;
    });
    widget.googleMapController.hideMarkerInfoWindow(markerInfo.getMarkerId());
    await DbMainMethods.subtractPoint(markerCoordinates, markerInfo.markerType, centersSet.toList());
    await updateMarkers();
    // setState(() {});
  }

  //создание ID метки
  String markerIdGen(LatLng coordinates) {
    return coordinates.latitude.toString() + coordinates.longitude.toString();
  }

  FloatingActionButton confirmMarkerFAB(MarkerInfo dbMarker) {
    return FloatingActionButton(
      onPressed: () {
        confirmMarker(dbMarker);
        // Navigator.pop(context);
      },
      child: Icon(Icons.arrow_upward_outlined),
      backgroundColor: Colors.lightGreen,
    );
  }

  FloatingActionButton subtractMarkerFAB(MarkerInfo dbMarker) {
    return FloatingActionButton(
      onPressed: () {
        // dbMarker.confirms = dbMarker.confirms - 1;
        // setState(() {});
        subtractMarker(dbMarker);
        // Navigator.pop(context);
        // addMarker(dbMarker.coordinates);
      },
      child: Icon(Icons.arrow_downward_outlined),
      backgroundColor: Colors.redAccent,
    );
  }

  double calculateBearing(LatLng prevDot, LatLng curDot) {
    var x = curDot.latitude - prevDot.latitude;
    var y = curDot.longitude - prevDot.longitude;
    if (y == 0) {
      return 25;
    }
    return atan(x / y) * 360 / (2 * pi);
  }
}
