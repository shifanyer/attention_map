import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/themes/theme_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../global/globals.dart' as globals;

class MarkerScale extends StatefulWidget {
  MarkerInfo markerInfo;
  // Map<MarkerId, int> userDecisions;

  MarkerScale({Key key, @required this.markerInfo}) : super(key: key);

  @override
  _MarkerScaleState createState() => _MarkerScaleState();
}

class _MarkerScaleState extends State<MarkerScale> with ThemeOne{
  double boxSize;
  double spaceBetween;
  double lineHeight;
  double lineLength;
  int confirmsFor;
  int confirmsAgainst;

  @override
  void initState() {
    confirmsFor = widget.markerInfo.confirmsFor;
    confirmsAgainst = widget?.markerInfo?.confirmsAgainst ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    boxSize = 30.0;
    spaceBetween = 25.0;
    lineHeight = 12.0;
    // confirmsFor = widget.markerInfo.confirmsFor;
    // confirmsAgainst = widget?.markerInfo?.confirmsAgainst ?? 0;
    lineLength = MediaQuery.of(context).size.width - boxSize * 5 - spaceBetween * 2 - 10.0;
    var forPercent = confirmsFor / (confirmsFor + confirmsAgainst);
    return Container(
      height: boxSize * 2.5,
      width: boxSize * 2 + spaceBetween + lineLength + spaceBetween + boxSize * 2,
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: boxSize * 2,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (globals.userDecisions[widget.markerInfo.getMarkerId()] != 1) {
                        if (globals.userDecisions[widget.markerInfo.getMarkerId()] == -1) {
                          confirmsAgainst--;
                          widget.markerInfo.confirmsAgainst--;
                        }
                        confirmsFor++;
                        widget.markerInfo.confirmsFor += 1;
                        globals.userDecisions[widget.markerInfo.getMarkerId()] = 1;

                      }
                      // confirmsFor++;
                      // widget.markerInfo.confirmsFor += 1;
                      // widget.userDecisions[widget.markerInfo.getMarkerId()] = 1;
                    });
                  },
                  backgroundColor: forColor,
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
                  color: (globals.userDecisions[widget.markerInfo.getMarkerId()] == 1) ? Colors.black : Colors.transparent,
                ),
              ),
            ],
          ),
          SizedBox(width: spaceBetween),
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
                            decoration: BoxDecoration(color: againstColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                          ),
                        Container(
                          width: lineLength * ((forPercent < 0.5) ? 1 : forPercent),
                          decoration: BoxDecoration(color: forColor, borderRadius: BorderRadius.all(Radius.circular(5))),
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
                                decoration: BoxDecoration(color: againstColor, borderRadius: BorderRadius.all(Radius.circular(5))),
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
                      if (globals.userDecisions[widget.markerInfo.getMarkerId()] != -1) {
                        if (globals.userDecisions[widget.markerInfo.getMarkerId()] == 1) {
                          confirmsFor--;
                          widget.markerInfo.confirmsFor --;
                        }
                        confirmsAgainst++;
                        widget.markerInfo.confirmsAgainst += 1;
                        globals.userDecisions[widget.markerInfo.getMarkerId()] = -1;

                      }
                    });
                  },
                  backgroundColor: againstColor,
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
                  color: (globals.userDecisions[widget.markerInfo.getMarkerId()] == -1) ? Colors.black : Colors.transparent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
