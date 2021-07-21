import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global/globals.dart' as globals;
import '../global/languages.dart' as languages;

class LanguageSwitcher extends StatefulWidget {
  @override
  _LanguageSwitcherState createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
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
                child: Text(languages.textsMap[globals.languages]['settings']['language_switcher']['language'], style: TextStyle(fontSize: 22.0),),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                  icon: Icon(Icons.ac_unit_sharp),
                onPressed: () {
                    setState(() {
                      if (globals.languages == 'ru') {
                        globals.languages = 'en';
                      }
                      else {
                        globals.languages = 'ru';
                      }
                    });
                },),
            ),
          ),
        ],
      ),
    );
  }
}