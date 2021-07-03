import 'package:attention_map/enums/marker_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectPointType extends StatelessWidget {

  final ValueChanged<MarkerType> pointType;

  static const typesList = [
    'Камера',
    'Достопримечательность',
    'Пост ДПС',
    'Опасный участок дороги',
    'ДТП',
    'Нужна помощь',
    'Другое'
  ];

  static List<MarkerType> markerTypesList = [
    MarkerType.camera,
    MarkerType.monument,
    MarkerType.dps,
    MarkerType.danger,
    MarkerType.dtp,
    MarkerType.help,
    MarkerType.other
  ];

  const SelectPointType({Key key, @required this.pointType}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      builder: (BuildContext context, ScrollController scrollController) {
        return ListView.builder(
          controller: scrollController,
          itemCount: typesList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                pointType(markerTypesList[index]);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(typesList[index], style: TextStyle(fontSize: 18),),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
