import 'dart:convert';
import 'dart:io';

import 'package:etender_app_1/models/push_notification.dart';
import 'package:etender_app_1/screens/delete_account.dart';
import 'package:etender_app_1/screens/ftender.dart';
import 'package:etender_app_1/screens/ftender_detail.dart';
import 'package:etender_app_1/screens/login.dart';
import 'package:etender_app_1/screens/ptender.dart';
import 'package:etender_app_1/screens/ptender_detail.dart';
import 'package:etender_app_1/screens/register.dart';
import 'package:etender_app_1/screens/reset_password.dart';
import 'package:etender_app_1/utils/email_change.dart';
import 'package:etender_app_1/utils/password_confirm.dart';
import 'package:etender_app_1/utils/phone_change.dart';
import 'package:etender_app_1/utils/user_setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'models/tender_model.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = new PostHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  List<OverlaySupportEntry> myEntrys = [];
  int entryCount = 0;

  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  String? fcmKey;

  bool isLoading = true;
  bool? logInState;

  @override
  void initState() {
    super.initState();

    initializePrefs();
    
    // handle message in foreground and background
    registerNotification();

    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('clicked on Message Notification');
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
      });
      goToTenderDetailedPageByBgNoti(message, message.data, checkState(message.data));
    });

    // check login
    isLogin();
  }

  initializePrefs() async {
    try{
      // for production
      var url = Uri.parse('https://eform.moee.gov.mm/api/etender_xOmfnoG1N7Nxgv');
      var response = await http.post(url, body: {});
      Map data = jsonDecode(response.body);
      print('data $data');

      if (data['success'] == true) {
        String apiPath = data['path'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_path', apiPath);
        setState(() {
          prefs.setString('api_path', apiPath);
        });
        print('main apiPath $apiPath');
      }
    }catch(e){
      print('exception for moep $e');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_path', 'https://ettest.moee.gov.mm/');
      setState(() {
        prefs.setString('api_path', 'https://ettest.moee.gov.mm/');
      });
      print('main apiPath https://ettest.moee.gov.mm/');
    }
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = await FirebaseMessaging.instance;

    // 3.subscribe to channel
    await _messaging.subscribeToTopic('alldevices').then((value) => print('device'));

    final fcmToken = await _messaging.getToken();
    print('fcm Token is $fcmToken');
    if(fcmToken != null){
      setState((){
        fcmKey = fcmToken;
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        isLoading = false;
        prefs.setString('fcm_key', fcmKey!);
      });
    }

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var api_token = prefs.getString('api_token');
    // if (api_token != null) {
    listeningNotiBackgroundAndForeGround();
    // }
  }

  void listeningNotiBackgroundAndForeGround() async {
    // Add the following line
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      print('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Message Listening in Foreground --------');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
        });

        print('Foreground message data is ${message.data}');

        if (_notificationInfo != null) {
          // _showCustomNotifcation();
          // For displaying the notification as an overlay
          int pos = entryCount;
          myEntrys.add(
            showSimpleNotification(
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                // child: Text(_notificationInfo!.title!),
                child: Text(_notificationInfo!.body!, style: TextStyle(
                  fontSize: 13
                ),),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Icon(Icons.notification_important),
              ),
              // subtitle: Padding(
              //   padding: const EdgeInsets.only(bottom: 15),
              //   child: Text(_notificationInfo!.body!),
              // ),
              background: Colors.red,
              duration: Duration(seconds: 10),
              autoDismiss: false,
              slideDismiss: true,
              // position: NotificationPosition.bottom,
              trailing: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: IconButton(
                  onPressed: () {
                    goToTenderDetailedPage(
                        message.data, checkState(message.data),
                        count: pos);
                  },
                  icon: Icon(Icons.arrow_right),
                ),
              ),
            ),
          );
          entryCount++;
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? loading() : OverlaySupport(
      child: MaterialApp(
        scaffoldMessengerKey: _messangerKey,
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => logInState == null ? loading() : 
                            (logInState == true ? Ftender() : Login()),
          '/login': (context) => Login(),
          '/ftender': (context) => Ftender(),
          '/ftender_detail': (context) => FtenderDetail(),
          '/ptender': (context) => Ptender(),
          '/ptender_detail': (context) => PtenderDetail(),
          '/delete_account': (context) => DeleteAccount(),
          '/register': (context) => Register(),
          '/reset_password': (context) => ResetPassword(),
          '/user_setting' :(context) => UserSetting(),
          '/email_change': (context) => EmailChange(),
          '/phone_change' : (contxt) => PhoneChange(),
          '/password_confirm' :(context) => PasswordConfirm(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Pyidaungsu'),
      ),
    );
  }

  Future<bool> isLogin() async {
    String apiPath = 'http://ettest.moee.gov.mm/';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    if (api_token != null) {
      try {
        var url = Uri.parse('${apiPath}api/check_member_login');
        var response = await http.post(url, body: {
          'apitoken': api_token,
        });
        Map data = jsonDecode(response.body);
        print("check member");
        print(data);
        if (data['success']) {
          setState((){
            logInState = true;
          });
          return true;
        } else {
          setState((){
            logInState = false;
          });
          return false;
        }
      } catch (e) {
        setState((){
          logInState = false;
        });
        return false;
      }
    } else {
      setState((){
          logInState = false;
        });
      return false;
    }
  }

  // loading widget ----- start
  Widget loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  // loading widget ----- end

  String checkState(Map tender) {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    DateTime todayDt = DateTime.parse(date.toString());
    DateTime closedDt = DateTime.parse(tender['closed_at']);
    String state = 'OPEN';
    if (todayDt.compareTo(closedDt) > 0) {
      state = 'CLOSE';
    }
    return state;
  }

  void goToTenderDetailedPage(Map tender, String state, {int? count}) async {
    bool login = await isLogin();

    print('coount $count');

    if (login) {
      if (count != null) {
        OverlaySupportEntry entry = myEntrys.elementAt(count);
        entry.dismiss();
      }

      navigatorKey.currentState?.pushNamed(
        tender['type'].toString() == 'free' ? '/ftender_detail' : '/ptender_detail',
        arguments: TenderModel(
          id: tender['id'].toString(),
          type: tender['type'].toString(),
          serial: tender['serial'].toString(),
          title: tender['title'].toString(),
          description: tender['description'].toString(),
          department: tender['agency'].toString(),
          price: tender['price'].toString(),
          currency: tender['currency'].toString(),
          publishedAt: tender['published_at'].toString(),
          closedAt: tender['closed_at'].toString(),
          downloadAt: tender['download_at'].toString(),
          state: state,
        ),
      );
    } else {
      showSnackBarLogin(context, "Please login First!");
    }
  }

  void goToTenderDetailedPageByBgNoti(RemoteMessage message, Map tender, String state, {int? count}) async {
    bool login = await isLogin();

    print('coount $count');

    if (login) {
      if (count != null) {
        OverlaySupportEntry entry = myEntrys.elementAt(count);
        entry.dismiss();
      }

      navigatorKey.currentState?.pushNamed(
        tender['type'].toString() == 'free' ? '/ftender_detail' : '/ptender_detail',
        arguments: TenderModel(
          id: tender['id'].toString(),
          type: tender['type'].toString(),
          serial: tender['serial'].toString(),
          title: tender['title'].toString(),
          description: tender['description'].toString(),
          department: tender['agency'].toString(),
          price: tender['price'].toString(),
          currency: tender['currency'].toString(),
          publishedAt: tender['published_at'].toString(),
          closedAt: tender['closed_at'].toString(),
          downloadAt: tender['download_at'].toString(),
          state: state,
        ),
      );
    } else {
        if (_notificationInfo != null) {
          // _showCustomNotifcation();
          // For displaying the notification as an overlay
          int pos = entryCount;
          myEntrys.add(
            showSimpleNotification(
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(_notificationInfo!.title!),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Icon(Icons.notification_important),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(_notificationInfo!.body!),
              ),
              background: Colors.blue,
              duration: Duration(seconds: 10),
              autoDismiss: false,
              // position: NotificationPosition.bottom,
              slideDismiss: true,
              trailing: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: IconButton(
                  onPressed: () {
                    goToTenderDetailedPage(
                        message.data, checkState(message.data),
                        count: pos);
                  },
                  icon: Icon(Icons.arrow_right),
                ),
              ),
            ),
          );
          entryCount++;
        }
      showSnackBarLogin(context, "Please login First!");
    }
  }

  void showSnackBarLogin(BuildContext context, String text) {
    _messangerKey.currentState?.showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: "CLOSE",
        onPressed: () {
          _messangerKey.currentState?.hideCurrentSnackBar();
        },
      ),
    ));
  }
}
