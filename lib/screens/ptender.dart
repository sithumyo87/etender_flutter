import 'dart:convert';
import 'package:etender_app_1/models/ptender_model.dart';
import 'package:etender_app_1/models/tender_model.dart';
import 'package:flutter/material.dart';
import 'package:etender_app_1/utils/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Ptender extends StatefulWidget {
  const Ptender({Key? key}) : super(key: key);

  @override
  State<Ptender> createState() => _PtenderState();
}

enum ConfirmAction { CANCEL, ACCEPT }

class _PtenderState extends State<Ptender> {

  bool isLoading = true;
  bool isError = false;
  String start = '0';
  String limit = '20';
  List<dynamic> ptenderList = [];

  @override
  void initState() {
    super.initState();
    // getPrefs();
    getPtenders();
  }

  // getting getPtenders data ----- start
  getPtenders() async {
    // try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');
    try {
      var url = Uri.parse('${apiPath}api/member_ptender_list');
      var response = await http.post(url, body: {
        'start': this.start,
        'limit': this.limit,
        'apitoken': api_token,
      });
      // Map data = jsonDecode(response.body);
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        ptenderList = data['tenders'];
        print(ptenderList);
      } else {
        // print('api token is $api_token');
        // print(data);
        setState(() {
          isError = true;
        });
        logout();
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logout();
    }
  }
  // getting ptenders data ----- end

  // showAlertDialog function ----- start
  void showAlertDialog(String title, String content, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('CLOSE'),
              )
            ],
          );
        });
  }
  // showAlertDialog function ----- end

  // loading widget ----- start
  Widget loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  // loading widget ----- end

  void doNothing(BuildContext context) {}

  // list item widget ----- start
  Widget swipListItem(BuildContext context, Map<dynamic, dynamic> tender) {
    bool isDownload = tender['download_at'] != null ? true : false;

    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    DateTime todayDt = DateTime.parse(date.toString());
    DateTime closedDt = DateTime.parse(tender['closed_at']);
    String state = 'OPEN';
    if (todayDt.compareTo(closedDt) > 0) {
      state = 'CLOSE';
    }

    return Column(
      children: [
        Slidable(
            // Specify a key if the Slidable is dismissible.
            key: const ValueKey(0),

            // The child of the Slidable is what the user sees when the
            // component is not dragged.
            child: Stack(
              children: [
                isDownload
                    ? Positioned(
                        top: 15,
                        right: -20.0,
                        child: Transform.rotate(
                          angle: 120,
                          child: Container(
                            padding: EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: 50.0,
                              right: 35.0,
                            ),
                            color: Colors.lightBlue,
                            child: Text(
                              'downloaded',
                              style: TextStyle(
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ))
                    : SizedBox(),
                ListTile(
                  horizontalTitleGap: 16.0,
                  minVerticalPadding: 20.0,
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                  title: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 5),
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
                            height: 10,
                          ),
                          Icon(
                            Icons.download,
                            size: 20.0,
                          ),
                          Text(
                            '7',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tender['title'].toString(),
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'ID Number : ${tender['serial'].toString()}',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            Text(
                              'Published On : ${tender['published_date'].toString()}',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            Text(
                              'Closed On : ${tender['closed_date'].toString()}',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Type : ',
                                  style: TextStyle(fontSize: 13.0),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.0,
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.green,
                                  ),
                                  child: Text(
                                    'Paid',
                                    style: TextStyle(fontSize: 10.0),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/ptender_detail',
                      arguments: TenderModel(
                        id: tender['id'].toString(),
                        type: tender['type'].toString(),
                        serial: tender['serial'].toString(),
                        title: tender['title'].toString(),
                        description: tender['description'].toString(),
                        department: tender['agency'].toString(),
                        price: tender['price'].toString(),
                        currency: tender['currency'].toString(),
                        publishedAt: tender['published_date'].toString(),
                        closedAt: tender['closed_date'].toString(),
                        downloadAt: tender['download_at'].toString(),
                        state: state,
                      ),
                    );
                  },
                ),
              ],
            )),
        SizedBox(height: 10.0)
      ],
    );
  }
  // list item widget ----- end

  // loading widget ----- start
  Widget body() {
    return RefreshIndicator(
      onRefresh: () async {
        getPtenders();
      },
      child: Container(
        child: Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: ptenderList.length,
                  itemBuilder: (context, index) {
                    return swipListItem(context, ptenderList[index]);
                  },
                ),
              ),
            ]),
          ),
        ]),
      ),
      color: Colors.purple,
    );
  }
  // loading widget ----- end

  // body widget ----- start
  Widget errorWid() {
    return Center(
      child: Text('Connection Failed! Check internect connecton'),
    );
  }
  // body widget ----- end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paid Tenders',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: isLoading ? loading() : (isError ? errorWid() : body()),
      drawer: AppDrawer(),
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
