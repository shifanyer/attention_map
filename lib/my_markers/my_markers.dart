import 'package:attention_map/enums/enumMethods.dart';
import 'package:attention_map/enums/marker_type.dart';
import 'package:attention_map/local_db/write_in_file.dart';
import 'package:attention_map/map_objects/marker_page.dart';
import 'package:attention_map/themes/theme_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../global/globals.dart' as globals;

class MyMarkers extends StatefulWidget with ThemeOne {
  static List<String> markerImageAssets = [
    'assets/camera_marker.png',
    'assets/monument_marker.png',
    'assets/dps_marker.png',
    'assets/danger_marker.png',
    'assets/dtp_marker.png',
    'assets/help_marker.png',
    'assets/other_marker.png',
  ];

  static List<double> markerPercentage = [30.01, 51.32, 25.55, 100.0, 95.83, 33.33, 66.67];

  @override
  _MyMarkersState createState() => _MyMarkersState();
}

class _MyMarkersState extends State<MyMarkers> {
  var cardHeight = 105.0;

  var edgeCornerRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 5,
        title: Center(
          child: Text(
            'Мои маркеры',
            style: TextStyle(
              color: Color(0xFF5C5C5C),
              fontSize: 45,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        toolbarHeight: 150,
        backgroundColor: Color(0xFFDEDEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /*
            SliverAppBar(
              shadowColor: Colors.black,
              elevation: 6.0,
              collapsedHeight: 100,
              expandedHeight: 200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              automaticallyImplyLeading: true,
              backgroundColor: Color(0xFFDEDEDE),
              // backgroundColor: Colors.transparent,
              pinned: true,
              snap: false,
              floating: true,
              // expandedHeight: 100.0,
/*
              title: Text(
                'Мои маркеры',
                style: TextStyle(
                  color: Color(0xFF5C5C5C),
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                ),
              ),
*/
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                stretchModes: [StretchMode.fadeTitle],
                background: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFDEDEDE),
                      boxShadow: [BoxShadow(blurRadius: 3)],
                      borderRadius: new BorderRadius.only(
                        bottomRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      )
                  ),
                ),
                title: Center(
                  child: Text(
                    'Мои маркеры',
                    style: TextStyle(
                      color: Color(0xFF5C5C5C),
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),


            ),
            */

            // for (var i = 0; i < globals.userMarkers.length; i++)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            for (var markerInfo in globals.userMarkers.values)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 4,
                    height: cardHeight,
                    child: Dismissible(
                      key: Key(markerInfo.getMarkerId().value),
                      background: redDeleteDismiss(false),
                      secondaryBackground: redDeleteDismiss(true),
                      onDismissed: (_) {
                        setState(() {
                          globals.userMarkers.remove(markerInfo.getMarkerId().value);
                          FileOperations.writeUserMarkers();
                          //TODO добавить удаление из БД
                        });
                      },
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => MarkerPage(
                                      markerInfo: markerInfo, imagePath: 'assets/${EnumMethods.enumToString(markerInfo.markerType)}_marker.png')));
                          setState(() {});
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(edgeCornerRadius),
                          ),
                          color: Color(0xFFFCFCFC),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: cardHeight,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: (markerInfo.getPercentage() >= 50) ? ThemeOne().more50 : ThemeOne().less50,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(edgeCornerRadius),
                                          topRight: Radius.circular(1.0),
                                          bottomLeft: Radius.circular(edgeCornerRadius),
                                          bottomRight: Radius.circular(1.0),
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: Image.asset('assets/${EnumMethods.enumToString(markerInfo.markerType)}_marker.png'),
                                    // child: Image.asset('assets/dps_marker.png'),
                                  ),
                                  Container(
                                    height: cardHeight,
                                    width: MediaQuery.of(context).size.width / 1.8,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: (cardHeight - 2 * cardHeight / 2.5) / 2,
                                        ),
                                        Container(
                                          height: cardHeight / 2.5,
                                          width: MediaQuery.of(context).size.width / 2.4,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                width: cardHeight / 2.5,
                                                height: cardHeight / 2.5,
                                                child: Image.asset('assets/heart_like.png'),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 5),
                                                child: Text(
                                                  '- ${markerInfo.getHumanReadablePercentage()} %',
                                                  style: TextStyle(fontSize: 40),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: cardHeight / 2.5,
                                          child: Center(
                                            child: Text(
                                              'Подтверждений: ${markerInfo.confirmsFor}',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),

                              /*
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => MarkerPage(
                                              markerInfo: markerInfo,
                                              imagePath: 'assets/${EnumMethods.enumToString(markerInfo.markerType)}_marker.png')));
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: cardHeight,
                                      width: 20,
                                      decoration: BoxDecoration(
                                          color: (markerInfo.getPercentage() >= 50) ? ThemeOne().more50 : ThemeOne().less50,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(edgeCornerRadius),
                                            topRight: Radius.circular(1.0),
                                            bottomLeft: Radius.circular(edgeCornerRadius),
                                            bottomRight: Radius.circular(1.0),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      child: Image.asset('assets/${EnumMethods.enumToString(markerInfo.markerType)}_marker.png'),
                                      // child: Image.asset('assets/dps_marker.png'),
                                    ),
                                    Container(
                                      height: cardHeight,
                                      width: MediaQuery.of(context).size.width / 1.8,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: (cardHeight - 2 * cardHeight / 2.5) / 2,
                                          ),
                                          Container(
                                            height: cardHeight / 2.5,
                                            width: MediaQuery.of(context).size.width / 2.4,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  width: cardHeight / 2.5,
                                                  height: cardHeight / 2.5,
                                                  child: Image.asset('assets/heart_like.png'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 5),
                                                  child: Text(
                                                    '- ${markerInfo.getHumanReadablePercentage()} %',
                                                    style: TextStyle(fontSize: 40),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: cardHeight / 2.5,
                                            child: Center(
                                              child: Text(
                                                'Подтверждений: ${markerInfo.confirmsFor}',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),

                               */
                              Container(
                                width: cardHeight / 2.3,
                                height: cardHeight / 2.5,
                                // child: Image.asset('assets/geo_icon_button.png'),
                                child: Icon(Icons.arrow_forward_ios_outlined),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                /*
                child: Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(width: 1), bottom: BorderSide(width: 1))),
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: Colors.black, width: 1)),
                            color: (markerPercentage[i] >= 50) ? forColor : againstColor),
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
                      Text(
                        '${markerPercentage[i]} % -  ',
                        style: TextStyle(fontSize: 25),
                      ),
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
                */
              ),
          ],
        ),
      ),
    );
  }

  Container redDeleteDismiss(bool isRight) {
    return Container(
      color: Colors.red,
      child: Align(
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: isRight ? const EdgeInsets.only(right: 15.0) : const EdgeInsets.only(left: 15.0),
            child: Icon(Icons.delete),
          )),
    );
  }

  openMap() {
    print('openMap');
    //TODO функция, которая открывает карту с переданной меткой.
  }
}
