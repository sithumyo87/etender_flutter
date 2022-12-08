import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    Icons.person, AppLocalizations.of(context)!.name_change, name),
                settingWidget(
                    Icons.phone, AppLocalizations.of(context)!.phone_change, phone),
                settingWidget(
                    Icons.email, AppLocalizations.of(context)!.email_change, email),
                settingWidget(Icons.password_rounded, AppLocalizations.of(context)!.reset_psw, password),
                settingWidget( Icons.delete_forever, AppLocalizations.of(context)!.account_deletion, accDelClick,Colors.red),
                settingWidget(
                    Icons.language, AppLocalizations.of(context)!.language_change, lang),
              ]),
            )
          ],
        ),
      );
  }

  Widget settingWidget(icon, text, _onTap,[color]) {
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
                        child: Text(text,style: TextStyle(color: color)),
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
      title:  Text(AppLocalizations.of(context)!.user_setting,
          style: TextStyle(fontSize: 18.0)),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          goToBack();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            goToHomePage(context);
          },
          icon: const Icon(
            Icons.home,
            size: 18.0,
          ),
        ),
      ],
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

  void name(){
    Navigator.pushNamed(
        context, '/name_change');
  }

void accDelClick() async{
    var url = 'http://eformexample.moee.gov.mm/accountDeletion';
    if (await canLaunch(url))
      await launch(url);
    else
      throw "Could not launch $url";
  }

  
}
