import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global/globals.dart' as globals;

class ThemeSwitcher extends StatefulWidget {
  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        color: Color(0xFFE6E6E6),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Text('Тёмная тема', style: TextStyle(fontSize: 25.0),),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Switch(
                value: globals.isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    globals.isDarkTheme = value;
                  });
                },
                activeColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}