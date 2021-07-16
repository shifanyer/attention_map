import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme_switcher.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double switchersLeftPadding = MediaQuery.of(context).size.width * 0.1;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: [
              SizedBox(
                height: 40,
              ),

              //avatar
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFB7A0)),
                ),
              ),

              SizedBox(
                height: 40,
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20, right: 20),
                    child: Text(
                      'Ashka - Govnyashka',
                      style: TextStyle(fontSize: 30),
                    ),
                  )),
                  decoration: BoxDecoration(
                    color: Color(0xFFB6B6B6),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              // theme switcher
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0 + switchersLeftPadding),
                    child: ThemeSwitcher(),
                  )),

              SizedBox(
                height: 30,
              ),

              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              // language switcher
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0 + switchersLeftPadding),
                    child: ThemeSwitcher(),
                  )),

              SizedBox(
                height: 30,
              ),

              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Divider(
                    thickness: 2,
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              // notifications switcher
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0 + switchersLeftPadding),
                    child: ThemeSwitcher(),
                  )),

              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
