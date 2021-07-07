import 'package:attention_map/map_objects/marker_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerScale extends StatefulWidget {
  MarkerInfo markerInfo;
  Map<MarkerId, int> userDecision;

  MarkerScale({Key key, @required this.markerInfo, @required this.userDecision}) : super(key: key);

  @override
  _MarkerScaleState createState() => _MarkerScaleState();
}

class _MarkerScaleState extends State<MarkerScale> {
  double boxSize;
  double spaceBetween;
  double lineHeight;
  double lineLength;
  int confirmsFor;
  int confirmsAgainst;

  @override
  void initState() {
    print(widget.markerInfo.markerType);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    boxSize = 30.0;
    spaceBetween = 25.0;
    lineHeight = 12.0;
    confirmsFor = widget.markerInfo.confirmsFor;
    confirmsAgainst = widget.markerInfo.confirmsAgainst;
    lineLength = MediaQuery.of(context).size.width - boxSize * 5 - spaceBetween * 2 - 10.0;
    var forPercent = confirmsFor / (confirmsFor + confirmsAgainst);
    return Container(
      height: boxSize * 2.5,
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: boxSize * 2,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      confirmsFor++;
                      widget.markerInfo.confirmsFor += 1;
                      widget.userDecision[widget.markerInfo.getMarkerId()] = 1;
                    });
                    print('pressed for');
                  },
                  backgroundColor: Color(0xff33ff33),
                  child: Container(width: boxSize, height: boxSize, child: Image.asset('assets/likeUPD.png', fit: BoxFit.fill)),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                width: boxSize * 1.9,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: (widget.userDecision[widget.markerInfo.getMarkerId()] == 1) ? Colors.black : Colors.transparent,
                ),
              ),
            ],
          ),
          SizedBox(width: spaceBetween),
          // Container(width: MediaQuery.of(context).size.width - 60.0 * 2 - 20.0 * 2 - 10.0, height: 7, color: Colors.cyan,),

          Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                '${(forPercent * 100).truncate()} %',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Container(
                    width: lineLength,
                    height: lineHeight,
                    child: Stack(
                      children: [
                        if ((forPercent >= 0.5))
                          Container(
                            decoration: BoxDecoration(color: Color(0xffff0000), borderRadius: BorderRadius.all(Radius.circular(5))),
                          ),
                        Container(
                          width: lineLength * ((forPercent < 0.5) ? 1 : forPercent),
                          decoration: BoxDecoration(color: Color(0xff33ff33), borderRadius: BorderRadius.all(Radius.circular(5))),
                        ),
                        if (forPercent < 0.5)
                          Row(
                            children: [
                              Container(
                                width: lineLength * (forPercent),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                              Container(
                                width: lineLength * (1 - forPercent),
                                decoration: BoxDecoration(color: Color(0xffff0000), borderRadius: BorderRadius.all(Radius.circular(5))),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(width: spaceBetween),

          Column(
            children: [
              Container(
                width: boxSize * 2,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      confirmsAgainst++;
                      widget.markerInfo.confirmsAgainst += 1;
                      widget.userDecision[widget.markerInfo.getMarkerId()] = -1;
                    });
                    print('pressed for');
                  },
                  backgroundColor: Color(0xffff0000),
                  child: Container(width: boxSize, height: boxSize, child: Image.asset('assets/dislikeUPD.png', fit: BoxFit.fill)),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                width: boxSize * 1.9,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: (widget.userDecision[widget.markerInfo.getMarkerId()] == -1) ? Colors.black : Colors.transparent,
                ),
              ),
            ],
          ),
          /*
          Container(
            width: boxSize * 2,
            child: FloatingActionButton(
              onPressed: () {
                print('pressed against');
              },
              backgroundColor: Color(0xffff0000),
              child: Container(
                  width: boxSize,
                  height: boxSize,
                  child: Image.asset(
                    'assets/dislikeUPD.png',
                    fit: BoxFit.fill,
                  )),
            ),
          )
          ,
           */
        ],
      ),
    );
  }
}
