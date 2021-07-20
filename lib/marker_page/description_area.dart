import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/marker_page/edit_description_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DescriptionArea extends StatefulWidget {
  MarkerInfo markerInfo;

  DescriptionArea({Key key, @required this.markerInfo}) : super(key: key);

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
                  'Описание:',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 28),
                )),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => EditDescriptionArea(
                              markerInfo: widget.markerInfo,
                            )));
                setState(() {});
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(width: 1, color: Colors.blueGrey)),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: SelectableText(
                      (widget?.markerInfo?.descriptionText == null)
                          ? 'Нажмите, чтобы добавить описание'
                          : ((widget.markerInfo.descriptionText == '') ? 'Нажмите, чтобы добавить описание' : widget.markerInfo.descriptionText),
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 500,
                      style: TextStyle(fontSize: 17),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => EditDescriptionArea(
                                      markerInfo: widget.markerInfo,
                                    )));
                        setState(() {});
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
