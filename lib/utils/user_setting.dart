import 'package:etender_app_1/utils/app_drawer.dart';
import 'package:flutter/material.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: applicationBar(),
        body:   Column(
          children: [
            Expanded(
              child: ListView(children: [
                settingWidget(
                    Icons.phone, 'Chaneg Phone Number',phone),
                settingWidget(Icons.email, 'Change Email', email),
                settingWidget(Icons.password_rounded, 'Change Email', password),
              ]),
            )
          ],
        ),
        drawer: AppDrawer(),
      );
  }

  Widget settingWidget(icon, text, _onTap) {
    var msize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 5),
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            splashColor: Colors.lightBlueAccent,
            onTap: _onTap,
            child: Container(
              width: msize.width,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        icon,
                        color: Colors.black38,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(text),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_right,
                    color: Colors.black45,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 AppBar applicationBar() {
    return AppBar(
      centerTitle: true,
      title:  Text('Settting',
        style: TextStyle(fontSize: 18.0)),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          goToBack();
        },
      ),
    );
  }

  void goToBack() {
    Navigator.of(context).pop();
  }

  void goToHomePage(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, '/division_choice', (route) => false);
  }

  void lang() {
    Navigator.pushNamed(
        context, '/lang');
  }

  void phone() {
     Navigator.pushNamed(
        context, '/phone_change');
  }

  void email() {
     Navigator.pushNamed(
        context, '/email_change');
  }

  void password() {
     Navigator.pushNamed(
        context, '/password_confirm');
  }

  
}
