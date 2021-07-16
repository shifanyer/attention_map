import 'dart:async';
import 'dart:math';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/enums/enumMethods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/filters/marker_filters.dart';
import 'package:attention_map/local_db/write_in_file.dart';
import 'package:attention_map/map_objects/marker_page.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/map_objects/marker_scale.dart';
import 'package:flutter/cupertino.dart';
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
import '../global/globals.dart' as globals;

class MainMap extends StatefulWidget {
  LatLng startCameraPosition;
  final List<MarkerInfo> markersList;
  final Map<MarkerType, BitmapDescriptor> customMarkers;

  MainMap({Key key, this.startCameraPosition, @required this.markersList, @required this.customMarkers})
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
  Map<MarkerId, int> userDecisions = {};
  double zoomValue = 17.0;
  bool followLocation = true;
  bool isAutoCameraMove = true;
  MarkerInfo changeMarkerInfo;
  bool ifChangeMarkerInfo = false;
  LatLng prevDot;
  Set<Circle> circles = {};

  static const typesList = ['Камера', 'Достопримечательность', 'Пост ДПС', 'Опасный участок дороги', 'ДТП', 'Нужна помощь', 'Другое'];

  var filtersList = [true, true, true, true, true, true, true];

  static List<MarkerType> markerTypesList = [
    MarkerType.camera,
    MarkerType.monument,
    MarkerType.dps,
    MarkerType.danger,
    MarkerType.dtp,
    MarkerType.help,
    MarkerType.other
  ];

  static List<String> markerImageAssets = [
    'assets/camera_marker.png',
    'assets/monument_marker.png',
    'assets/dps_marker.png',
    'assets/danger_marker.png',
    'assets/dtp_marker.png',
    'assets/help_marker.png',
    'assets/other_marker.png'
  ];

  // Marker marker;
  Location location = Location();

  // LatLng initialCameraPosition = LatLng(59.666999, 51.58008);
  LatLng initialCameraPosition;

  bool showMarkersList;

  @override
  void initState() {
    showMarkersList = true;
    customMarkers = widget.customMarkers;
    initialCameraPosition = widget.startCameraPosition;
    if (widget?.startCameraPosition != null) {
      initialCameraPosition = widget.startCameraPosition;
    }
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
    globals.googleMapController = _cntlr;
    if (followLocation) {
      isAutoCameraMove = true;
      globals.googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude), zoom: zoomValue, tilt: 15.0, bearing: 25),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: LayoutBuilder(
            builder: (BuildContext safeAreaContext, BoxConstraints constraints) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: [
                      //карта
                      Stack(
                        children: [
                          Container(
                            // height: MediaQuery.of(safeAreaContext).size.height * 0.75,
                            height: (showMarkersList) ? MediaQuery.of(safeAreaContext).size.height * 0.75 : constraints.maxHeight,
                            width: MediaQuery.of(context).size.width,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(target: initialCameraPosition, zoom: zoomValue),
                              compassEnabled: false,
                              mapType: MapType.normal,
                              onMapCreated: _onMapCreated,
                              myLocationEnabled: true,
                              markers: markers.toSet(),
                              circles: circles,
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
                          IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                setState(() {
                                  showMarkersList = !showMarkersList;
                                });
                              }),
                          Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                  icon: Icon(Icons.filter_alt),
                                  onPressed: () async {
                                    await Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => MarkerFilters(
                                                  filters: filtersList,
                                                  filtersNames: typesList,
                                                )));
                                    updateMarkers();
                                    print('Filters');
                                  })),
                          Padding(
                            padding: EdgeInsets.only(
                                top: ((showMarkersList) ? MediaQuery.of(safeAreaContext).size.height * 0.75 : constraints.maxHeight) - 80,
                                left: MediaQuery.of(context).size.width * 1 - 80),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () {
                                  followLocation = !followLocation;
                                  if (followLocation) {
                                    isAutoCameraMove = true;
                                    globals.googleMapController.animateCamera(
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
                                icon: Icon(
                                  Icons.adjust,
                                  color: followLocation ? Colors.black : Colors.white70,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (ifChangeMarkerInfo)
                        SizedBox(
                          height: (MediaQuery.of(context).size.height * 0.15 - 30 * 2.5) / 2,
                        ),
                      if (ifChangeMarkerInfo)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: MarkerScale(
                            markerInfo: changeMarkerInfo,
                          ),
                        ),
                      if (showMarkersList)
                        if (!ifChangeMarkerInfo)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: typesList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await addMarker(initialCameraPosition, pointType: markerTypesList[index]);
                                    print(typesList[index].toString());
                                  },
                                  child: Card(
                                    child: Padding(padding: const EdgeInsets.all(15.0), child: Image.asset(markerImageAssets[index])),
                                  ),
                                );
                              },
                            ),
                            /*
                      ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            width: 160.0,
                            color: Colors.red,
                          ),
                          Container(
                            width: 160.0,
                            color: Colors.blue,
                          ),
                          Container(
                            width: 160.0,
                            color: Colors.green,
                          ),
                          Container(
                            width: 160.0,
                            color: Colors.yellow,
                          ),
                          Container(
                            width: 160.0,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      */
                          ),

                      /*
                    Row(
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
                    )
                    */
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
      if (globals.googleMapController != null) {
        zoomValue = await globals.googleMapController.getZoomLevel();
      }
      if (followLocation) {
        var bearing = calculateBearing(prevDot, LatLng(_currentPosition.latitude, _currentPosition.longitude));
        isAutoCameraMove = true;
        globals.googleMapController.animateCamera(
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
        visible: (dbMarker.confirmsFor > 0) && (filtersList[markerTypesList.indexOf(dbMarker.markerType)]),
        infoWindow: InfoWindow(title: EnumMethods.getDescription(dbMarker.markerType), snippet: 'Подтвердили: ${dbMarker.confirmsFor}'),
        onTap: () async {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => MarkerPage(
                      markerInfo: dbMarker,
                      imagePath: markerImageAssets[markerTypesList.indexOf(dbMarker.markerType)])));
          return;

          if (followLocation) {
            isAutoCameraMove = true;
            globals.googleMapController.animateCamera(
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
                globals.googleMapController.hideMarkerInfoWindow(dbMarker.getMarkerId());
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
  Future<void> addMarker(LatLng location, {MarkerType pointType = MarkerType.noType}) async {
    // выбор типа точки
    /*
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

     */

    // Добавление точки внутри области
    /*
    circles = Set.from([
      Circle(
          circleId: CircleId(markerIdGen(LatLng(location.latitude, location.longitude))),
          center: LatLng(location.latitude, location.longitude),
          fillColor: Colors.orangeAccent.withOpacity(0.2),
          radius: 150,
          strokeWidth: 1)
    ]);
    markers.add(Marker(
      onDragEnd: (newPosition) {
        print('newPosition: ${location.latitude} : ${location.longitude} | ${newPosition.latitude} : ${newPosition.longitude}');
        var sqr = (location.latitude - newPosition.latitude) * (location.latitude - newPosition.latitude) +
            (location.longitude - newPosition.longitude) * (location.longitude - newPosition.longitude);
        var x = (location.latitude - newPosition.latitude) / sqr;
        var y = (location.longitude - newPosition.longitude) / sqr;
        print('${sqr}, ${sqrt(sqr) / 150}');

        if (sqrt(sqr) / 150 > 0.0000118) {
          Fluttertoast.showToast(
              msg: "Маркер должен находиться внутри радиуса",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        print(LatLng((location.latitude + 0.0000118 * x), (location.longitude + 0.0000118 * y)));



        // 0.0000035943208250804098,  0.0018958694113995324
        // 0.000004622836121367384,   0.002150078166338932
        // 0.000004689080907293477,   0.0021654285735838706
        // 0.000004886119992491786,   0.002210456964632378

        // 0.000005573479099843701,   0.000015738811334255063
        // 0.0000025618080164812444,  0.000010670432702839799
        // 0.0000031492852818927464,  0.000011830817163272736
        // 0.0000018822967510107873,  0.000009146454689017882
      },
      draggable: true,
      icon: customMarkers[pointType],
      markerId: MarkerId(markerIdGen(LatLng(location.latitude, location.longitude))),
      position: LatLng(location.latitude, location.longitude),
      // visible: (dbMarker.confirmsFor > 0) && (filtersList[markerTypesList.indexOf(dbMarker.markerType)]),
      infoWindow: InfoWindow(title: EnumMethods.getDescription(pointType), snippet: 'Подтвердили: ${1}'),
      onTap: () async {
        return;
        /*
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
            */
      },
      // consumeTapEvents: true,
    ));

    setState(() {});
    return;

    */

    var markerType = pointType;
    if (markerType == MarkerType.noType) {
      return;
    }
    // var latLon = await location.getLocation();
    var latLon = location;
    var markerCoordinates = LatLng(latLon.latitude, latLon.longitude);

    var mapMarkerId = MarkerId(markerIdGen(markerCoordinates));
    globals.userDecisions[mapMarkerId] = 1;
    FileOperations.writeUserDecisions();
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
    globals.googleMapController.hideMarkerInfoWindow(markerInfo.getMarkerId());
    setState(() {
      ifChangeMarkerInfo = false;
    });
    await DbMainMethods.uploadPoint(markerCoordinates, markerInfo.markerType, markerInfo.getCentersSet().toList());
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
    globals.googleMapController.hideMarkerInfoWindow(markerInfo.getMarkerId());
    await DbMainMethods.subtractPoint(markerCoordinates, markerInfo.markerType, centersSet.toList());
    await updateMarkers();
    // setState(() {});
  }

  //создание ID метки
  String markerIdGen(LatLng coordinates) {
    return coordinates.latitude.toString() + '_' + coordinates.longitude.toString();
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
//
// 55,1426914 : 61,238128700000004 | 55,144006946991574 : 61,23859662562609
// 0,001315546991574  0,000467925626086
// 0,000001949618278587377110676872
//
// 55,1426914 : 61,238128700000004 | 55,14197941087293 : 61,23613201081753
// (-0,00071198912707) (-0,001996689182474)
// 0,000004493696208474591075545576
