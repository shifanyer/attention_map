import 'package:attention_map/themes/theme_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyMarkers extends StatelessWidget with ThemeOne {
  static List<String> markerImageAssets = [
    'assets/camera_marker.png',
    'assets/monument_marker.png',
    'assets/DPS_marker.png',
    'assets/danger_marker.png',
    'assets/dtp_marker.png',
    'assets/help_marker.png',
    'assets/destination_map_marker.png'
  ];

  static List<double> markerPercentage = [30.01, 51.32, 25.55, 100.0, 95.83, 33.33, 66.67];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.blueAccent,
                ),
                title: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text('Мои маркеры'),
                ),
              ),
            ),
            for (var i = 0; i < markerImageAssets.length; i++)
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(width: 1), bottom: BorderSide(width: 1))),
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 1)), color: (markerPercentage[i] >= 50) ? forColor : againstColor),
                        width: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        child: Image.asset(markerImageAssets[i]),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Text('${markerPercentage[i]} % -  ', style: TextStyle(fontSize: 25),),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        child: FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: forColor,
                          child: Container(width: 40, height: 40, child: Image.asset('assets/likeUPD.png', fit: BoxFit.fill)),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      // IconButton(
                      //     icon: Icon(Icons.delete),
                      //     onPressed: () {
                      //       print('deleted');
                      //     }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
