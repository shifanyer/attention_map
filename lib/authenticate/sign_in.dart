import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bottom_bar.dart';

class SignIn extends StatefulWidget {

  final Map<MarkerType, BitmapDescriptor> markers;
  final List<MarkerInfo> markersList;

  const SignIn({Key key, this.markers, this.markersList}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ElevatedButton(
          onPressed: () async {
            dynamic result = await _auth.signInAnon();
            if (result == null) {
              print('error sign in');
            }
            else{
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => BottomBar(
                        markers: widget.markers,
                        markersList: widget.markersList,
                      )));
            }
          },
          child: Text('Sign in ANON'),
        ),
      ),
    );
  }
}
