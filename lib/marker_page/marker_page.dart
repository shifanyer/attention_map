import 'package:attention_map/enums/enumMethods.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:attention_map/map_objects/marker_scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'description_area.dart';

class MarkerPage extends StatelessWidget {
  final MarkerInfo markerInfo;
  final String imagePath;
  double imagesBorderRadius = 25.0;

  MarkerPage({Key key, @required this.markerInfo, @required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 150.0,
              collapsedHeight: MediaQuery.of(context).size.width / 5,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.blueAccent,
                ),
                title: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 7,
                      height: MediaQuery.of(context).size.width / 7,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          EnumMethods.translate(markerInfo.markerType),
                          maxLines: 50,
                          overflow: TextOverflow.ellipsis,
                        ))
                  ],
                ),
              ),
            ),

            // Картинки
            /*
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Прикреплённые фото:',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 28),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)), color: Colors.yellow,),
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)), color: Colors.yellow,),
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)), color: Colors.yellow,),
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)), color: Colors.yellow,),
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)), color: Colors.yellow,),
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            */

            //Описание
            DescriptionArea(markerInfo: markerInfo,),
            /*
            SliverToBoxAdapter(
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
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(width: 1, color: Colors.blueGrey)),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: SelectableText(
                              'На краю дороги стоял дуб. Он был, вероятно, в десять раз старше берез, составлявших лес, в десять раз толще и в два раза выше каждой березы. Это был огромный, в два обхвата дуб, с обломанными суками и корой, заросшей старыми болячками. С огромными, неуклюже, несимметрично растопыренными корявыми руками и пальцами, он старым, сердитым и презрительным уродом стоял между улыбающимися березами. Только он один не хотел подчиниться обаянию весны и не хотел видеть ни весны ни солнца.',
                              // maxLines: 500,
                              style: TextStyle(fontSize: 17),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),

             */
            //Лайки/дислайки

            SliverToBoxAdapter(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: MarkerScale(
                    markerInfo: markerInfo,
                  )),
            ),

            //Комментарии
            /*
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Комментарии:',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 28),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        Card(
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                width: 50,
                                height: 40,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Column(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width - 100,
                                      height: 30,
                                      child: Text(
                                        'Ivan',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        'Старый дуб, весь преображенный, раскинувшись шатром сочной, темной зелени, млел, чуть колыхаясь в лучах вечернего солнца.',
                                        maxLines: 500,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Card(
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width - 100,
                                      height: 30,
                                      child: Text(
                                        'Ashka',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        'Нет, жизнь не кончена в тридцать один год, — вдруг окончательно и бесповоротно решил князь Андрей.',
                                        maxLines: 500,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Card(
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width - 100,
                                      height: 30,
                                      child: Text(
                                        'Ivanashka',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        'Уже было начало июня, когда князь Андрей, возвращаясь домой, въехал опять в ту березовую рощу, в которой этот старый, корявый дуб так странно и памятно поразил его.',
                                        maxLines: 500,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }
}
