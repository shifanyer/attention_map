import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectPointType extends StatelessWidget {

  final ValueChanged<String> pointType;

  static const typesList = [
    'Камера',
    'Достопримечательность',
    'Пост ДПС',
    'Опасный участок дороги',
    'Другое'
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
                pointType(typesList[index]);
                Navigator.pop(context);
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(typesList[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
