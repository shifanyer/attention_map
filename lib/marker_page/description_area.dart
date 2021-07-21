import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/marker_page/edit_description_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/languages.dart' as languages;
import '../global/globals.dart' as globals;

class DescriptionArea extends StatefulWidget {
  MarkerInfo markerInfo;
  final bool blockEdit;

  DescriptionArea({Key key, @required this.markerInfo, @required this.blockEdit}) : super(key: key);

  @override
  _DescriptionAreaState createState() => _DescriptionAreaState();
}

class _DescriptionAreaState extends State<DescriptionArea> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  languages.textsMap[globals.languages]['marker_page']['description_area']['description'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 28),
                )),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                if (widget?.blockEdit ?? true){
                  Fluttertoast.showToast(
                      msg: 'Редактирование доступно только в разделе "Мои маркеры"',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.black26,
                      textColor: Colors.black,
                      fontSize: 16.0);
                }
                else {
                  await Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => EditDescriptionArea(
                                markerInfo: widget.markerInfo,
                              )));
                  setState(() {});
                }
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(width: 1, color: Colors.blueGrey)),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: SelectableText(
                      ((widget?.markerInfo?.descriptionText == null) || (widget.markerInfo.descriptionText == ''))
                          ? languages.textsMap[globals.languages]['marker_page']['description_area']['empty_text']
                          : widget.markerInfo.descriptionText,
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 500,
                      style: TextStyle(fontSize: 17),
                      onTap: () async {
                        if (widget?.blockEdit ?? true){
                          Fluttertoast.showToast(
                              msg: 'Редактирование доступно только в разделе "Мои маркеры"',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.black26,
                              textColor: Colors.black,
                              fontSize: 16.0);
                        }
                        else {
                          await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => EditDescriptionArea(
                                    markerInfo: widget.markerInfo,
                                  )));
                          setState(() {});
                        }
                      },
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
