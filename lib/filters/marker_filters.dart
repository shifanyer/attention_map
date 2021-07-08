import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MarkerFilters extends StatefulWidget {
  List<bool> filters;
  List<String> filtersNames;

  MarkerFilters({Key key, @required this.filters, @required this.filtersNames}) : super(key: key);

  @override
  _MarkerFiltersState createState() => _MarkerFiltersState();
}

class _MarkerFiltersState extends State<MarkerFilters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.filters.length,
        itemBuilder: (BuildContext context, int index) {
          return CheckboxListTile(
              title: Text(widget.filtersNames[index]),
              controlAffinity: ListTileControlAffinity.leading,
              value: widget.filters[index],
              onChanged: (value) {
                setState(() {
                  widget.filters[index] = value;
                });
              });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            for (var i = 0; i < widget.filters.length; i++) {
              widget.filters[i] = true;
            }
          });
        },
        label: Text('Сбросить'),
      ),
    );
    throw UnimplementedError();
  }
}
