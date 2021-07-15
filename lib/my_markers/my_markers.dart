import 'package:attention_map/themes/theme_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyMarkers extends StatelessWidget with ThemeOne {
  var cardHeight = 95.0;
  var edgeCornerRadius = 20.0;

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
    cardHeight = 95.0;
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 5,
        title: Center(
          child: Text(
            'Мои маркеры',
            style: TextStyle(
              color: Color(0xFF5C5C5C),
              fontSize: 40,
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

            for (var i = 0; i < markerImageAssets.length; i++)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 4,
                    height: cardHeight,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(edgeCornerRadius),
                      ),
                      color: Color(0xFFFCFCFC),
                      child: Row(
                        children: [
                          Container(
                            height: cardHeight,
                            width: 20,
                            decoration: BoxDecoration(
                                color: (markerPercentage[i] >= 50) ? ThemeOne().forColor : ThemeOne().againstColor,
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
                            child: Image.asset(markerImageAssets[i]),
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
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: cardHeight / 2.3,
                                        height: cardHeight / 2.5,
                                        child: Image.asset('assets/heart_like.png'),
                                      ),
                                      Text(
                                        ' - ${markerPercentage[i].truncate()} %',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: cardHeight / 2.5,
                                  child: Center(
                                    child: Text(
                                      'Подтверждений: 24',
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
                          GestureDetector(
                            onTap: openMap(),
                            child: Container(
                              width: cardHeight / 2.3,
                              height: cardHeight / 2.5,
                              child: Image.asset('assets/geo_icon_button.png'),
                            ),
                          ),
                        ],
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
}

openMap() {
  //TODO функция, которая открывает карту с переданной меткой.
}
