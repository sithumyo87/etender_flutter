import 'package:etender_app_1/utils/app_header.dart';
import 'package:etender_app_1/utils/app_link.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

enum ConfirmAction { CANCEL, ACCEPT }

class _AppDrawerState extends State<AppDrawer> {

  String? loginUserEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  // getting prefs data ----- start
  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String user_email = prefs.getString('user_email').toString();
    setState(() {
      loginUserEmail = user_email;
      isLoading = false;
    });
  }

  // loading widget ----- start
  Widget loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  // loading widget ----- end

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: isLoading ? loading() : Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                AppHeader('For Members', loginUserEmail!),
                AppLink(Icons.picture_as_pdf, 'Free tenders', () {
                  Navigator.pushReplacementNamed(context, '/ftender');
                }),
                AppLink(Icons.picture_as_pdf, 'Paid tenders', () {
                  Navigator.pushReplacementNamed(context, '/ptender');
                }),
                AppLink(Icons.delete_forever, 'Delete Account', () {
                  Navigator.pushReplacementNamed(context, '/delete_account');
                }),


                AppLink(Icons.settings, 'User Settings', () {
                  Navigator.pushReplacementNamed(context, '/user_setting');
                }),
              ],
            ),
          ),
          Text(
            'Logged-in as',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black26,
              fontSize: 14.0,
            ),
          ),
          Text(
            '$loginUserEmail',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Color.fromARGB(255, 224, 221, 221)),
              )
            ),
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: GestureDetector(
              onTap: () {
                _asyncConfirmDialog(context);
              },
              child: new Text(
                "LogOut",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  void accDelClick() async{
    var url = 'https://ettest.moee.gov.mm/deleteAccount';
    if (await canLaunch(url))
      await launch(url);
    else
      throw "Could not launch $url";
  }

  // logout alert  ----- start
  Future<Future<ConfirmAction?>> _asyncConfirmDialog(
      BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout?',
            style: TextStyle(fontSize: 16.0),
          ),
          content: const Text('Are you sure to logout?'),
          actions: <Widget>[
            	TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            	TextButton(
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                acceptConfirmBox(context);
                // _showSnackBar(context,'Sevice item is successfully deleted');
              },
            )
          ],
        );
      },
    );
  }
  // logout alert  ----- end

  void acceptConfirmBox(BuildContext context) async {
    Navigator.of(context).pop(ConfirmAction.ACCEPT);
    logout();
  }

  void logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('api_token');
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }
}
