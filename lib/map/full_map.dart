import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FullMap extends StatefulWidget {
  LatLng initialCameraPosition;
  double zoomValue;
  Function onMapCreated;
  Set markers;
  bool ifChangeMarkerInfo;
  bool isAutoCameraMove;
  bool followLocation;
  Location location;
  GoogleMapController googleMapController;

  FullMap({
    Key key,
    @required this.initialCameraPosition,
    @required this.zoomValue,
    @required this.onMapCreated,
    @required this.markers,
    @required this.ifChangeMarkerInfo,
    @required this.isAutoCameraMove,
    @required this.followLocation,
    @required this.location,
    @required this.googleMapController,
  }) : super(key: key);

  @override
  _FullMapState createState() => _FullMapState();
}

class _FullMapState extends State<FullMap> {
  LocationData currentPosition;

  @override
  void initState() {
    widget.initialCameraPosition = widget.initialCameraPosition;
    // getLoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Hero(
            tag: 'map tag',
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 1,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: widget.initialCameraPosition, zoom: widget.zoomValue),
                    compassEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: widget.onMapCreated,
                    myLocationEnabled: true,
                    markers: widget.markers,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    trafficEnabled: true,
                    onTap: (_) {
                      setState(() {
                        widget.ifChangeMarkerInfo = false;
                      });
                    },
                    onCameraMoveStarted: () {
                      setState(() {
                        if (!widget.isAutoCameraMove) widget.followLocation = false;
                      });
                    },
                    onCameraIdle: () {
                      setState(() {
                        if (widget.isAutoCameraMove) {
                          widget.followLocation = true;
                        }
                        widget.isAutoCameraMove = false;
                      });
                    },
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: Icon(Icons.filter_alt),
                        onPressed: () {
                          print('Filters');
                        })),
                Padding(
                  padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.95 - 80, left: MediaQuery.of(context).size.width * 1 - 80),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        widget.followLocation = !widget.followLocation;
                        if (widget.followLocation) {
                          widget.isAutoCameraMove = true;
                          widget.googleMapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                  target: LatLng(widget.initialCameraPosition.latitude, widget.initialCameraPosition.longitude),
                                  zoom: widget.zoomValue,
                                  tilt: 15.0,
                                  bearing: 25),
                            ),
                          );
                        }
                        setState(() {});
                      },
                      icon: Icon(Icons.adjust, color: widget.followLocation ? Colors.black : Colors.white70),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    throw UnimplementedError();
  }

  /*
  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await widget.location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await widget.location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await widget.location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await widget.location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentPosition = await widget.location.getLocation();
    widget.initialCameraPosition = LatLng(currentPosition.latitude, currentPosition.longitude);

    widget.location.onLocationChanged.listen((LocationData currentLocation) async {

      /*
      Set<String> updatedCentersSet = getCentersSet(currentLocation);
      if (!widget.centersSet.containsAll(updatedCentersSet)) {
        widget.centersSet = updatedCentersSet;
        await updateMarkers();
      }
      */
      // Zoom при перемещении обратно к геопозиции не меняется, если отдалиться или приблизиться
      if (widget.googleMapController != null) {
        widget.zoomValue = await widget.googleMapController.getZoomLevel();
      }

      if (widget.followLocation) {
        widget.isAutoCameraMove = true;
        widget.googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(currentLocation.latitude, currentLocation.longitude), zoom: widget.zoomValue, tilt: 15.0, bearing: 25),
          ),
        );
      }

      currentPosition = currentLocation;
      widget.initialCameraPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
    });
  }
*/
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
}
