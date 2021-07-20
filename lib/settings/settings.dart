import 'dart:io';
import 'dart:typed_data';

import 'package:attention_map/settings/language_switcher.dart';
import 'package:attention_map/local_db/write_in_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'notifications_switcher.dart';
import 'theme_switcher.dart';
import '../global/globals.dart' as globals;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  XFile avatar;

  TextEditingController _usernameController;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _usernameController.text =
        ((globals.userData['username'] == '') || (globals.userData['username'] == null)) ? 'Аноним' : globals.userData['username'];
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double switchersLeftPadding = MediaQuery.of(context).size.width * 0.05;
    var dividerWidth = MediaQuery.of(context).size.width * 0.9;
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
                child: GestureDetector(
                  onTap: () async {
                    avatar = await ImagePicker().pickImage(source: ImageSource.gallery);
                    var bytesAvatar = await avatar.readAsBytes();
                    globals.userData['avatar'] = bytesAvatar;
                    FileOperations.writeUserData();
                    setState(() {});
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width / 4)),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          color: Color(0xFFFFB7A0)),
                      child: (globals.userData['avatar'] != null) ? Image.memory(globals.userData['avatar'], fit: BoxFit.cover) : Container(),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 40,
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Color(0xFFB6B6B6),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  ),
                  child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20, right: 20),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 30),
                          onSubmitted: (_) {
                            globals.userData['username'] = _usernameController.text;
                            FileOperations.writeUserData();
                          },
                        ),
                      )),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Center(
                child: Container(
                  width: dividerWidth,
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
                  width: dividerWidth,
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
                    child: LanguageSwitcher(),
                  )),

              SizedBox(
                height: 30,
              ),

              Center(
                child: Container(
                  width: dividerWidth,
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
                    child: NotificationsSwitcher(),
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
