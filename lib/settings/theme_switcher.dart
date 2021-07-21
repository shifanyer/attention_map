import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global/globals.dart' as globals;
import '../global/languages.dart' as languages;

class ThemeSwitcher extends StatefulWidget {
  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.7,
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
                child: Text(languages.textsMap[globals.languages]['settings']['theme_switcher']['theme'], style: TextStyle(fontSize: 22.0),),
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