import 'dart:convert';

import 'package:etender_app_1/models/ftender_model.dart';
import 'package:etender_app_1/models/tender_model.dart';
import 'package:etender_app_1/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class FtenderDetail extends StatefulWidget {
  const FtenderDetail({Key? key}) : super(key: key);

  @override
  State<FtenderDetail> createState() => _FtenderDetailState();
}

enum ConfirmAction { CANCEL, ACCEPT }

class _FtenderDetailState extends State<FtenderDetail> {

  bool isLoading = true;
// define globalKey where other class have access(eg. top level scope)
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  // getting prefs data ----- start
  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');
    if (api_token != null && apiPath != null) {
      try {
        var url = Uri.parse('${apiPath}api/check_member_login');
        var response = await http.post(url, body: {
          'apitoken': api_token,
        });
        Map data = jsonDecode(response.body);
        print("check member");
        print(data);
        if (data['success']) {
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          logout();
        }
      } catch (e) {
        if (mounted) setState(() {
          isLoading = false;
        });
        print('Expection $e');
      }
    }
  }

  void downloadTender(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');
    var url = '${apiPath}member_ftender_download/$id/$api_token';
    if (await canLaunch(url))
      await launch(url);
    else
      throw "Could not launch $url";
  }

  Widget rowData(String attr, String value) {
    return Row(
      children: [
        Text(
          attr,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget titleWidget(String state, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          decoration: BoxDecoration(color: Colors.cyan),
          child: Text(
            state,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget body(args) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget(args.state, args.title),
              rowData('ID Number :', args.serial),
              rowData('Department :', args.department),
              SizedBox(height: 10.0),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rowData('Published Date :', args.publishedAt),
                    rowData('Closed Date :', args.closedAt),
                    SizedBox(height: 20.0),
                    Text(
                      args.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20.0),
                    Text('Cost : Free',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed: () {
                        downloadTender(args.id);
                      },
                      child: Text('Download PDF', style:TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TenderModel;

    return SafeArea(
      child: Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text(
            'Free Tenders',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        body: SingleChildScrollView(child: body(args)),
        drawer: AppDrawer(),
      ),
    );
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
                style: TextStyle(color: Colors.red),
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
