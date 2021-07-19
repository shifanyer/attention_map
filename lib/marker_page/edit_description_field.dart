import 'package:attention_map/map_objects/marker_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditDescriptionArea extends StatefulWidget {
  MarkerInfo markerInfo;

  EditDescriptionArea({Key key, @required this.markerInfo}) : super(key: key);

  @override
  _EditDescriptionAreaState createState() => _EditDescriptionAreaState();
}

class _EditDescriptionAreaState extends State<EditDescriptionArea> {
  TextEditingController _descriptionController;

  @override
  void initState() {
    _descriptionController = TextEditingController();
    _descriptionController.text = widget.markerInfo?.descriptionText ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавьте описание'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _descriptionController,
              showCursor: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Текст описания',
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                onPressed: () {
                  widget.markerInfo.descriptionText = _descriptionController.text;
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 35,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
