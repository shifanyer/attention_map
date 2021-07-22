import 'dart:io';
import 'dart:typed_data';

import 'package:attention_map/db_methods/db_main_methods.dart';
import 'package:attention_map/map_objects/marker_point.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagesArea extends StatefulWidget {
  final MarkerInfo markerInfo;

  const ImagesArea({Key key, @required this.markerInfo}) : super(key: key);

  @override
  _ImagesAreaState createState() => _ImagesAreaState();
}

class _ImagesAreaState extends State<ImagesArea> {
  XFile photo;
  var imagesList = <Uint8List>[];

  double imagesBorderRadius = 25.0;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
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
              child: FutureBuilder(
                  future: DbMainMethods.downloadImageUrls(widget.markerInfo),
                  builder: (context, snapshot) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (snapshot.hasData)
                          for (var imageURL in snapshot.data)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)),
                                  color: Colors.black26,
                                ),
                                width: MediaQuery.of(context).size.width / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageURL,
                                    placeholder: (context, url) => Container(
                                        width: 20,
                                        height: 20,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ))),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                        for (var image in imagesList)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)),
                                color: Colors.transparent,
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)),
                                  child: Image.memory(
                                    image,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                        if (!snapshot.hasData)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(imagesBorderRadius)),
                                color: Colors.transparent,
                              ),
                              width: MediaQuery.of(context).size.width / 2,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              photo = await ImagePicker().pickImage(source: ImageSource.gallery);
                              var bytesPhoto = await photo.readAsBytes();
                              File imageFile = File(photo.path);
                              imagesList.add(bytesPhoto);
                              DbMainMethods.uploadImage(widget.markerInfo, imageFile);
                              setState(() {});
                            })
                      ],
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
