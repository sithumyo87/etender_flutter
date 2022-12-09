import 'dart:convert';
import 'dart:io';
import 'package:etender_app_1/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PhoneChange extends StatefulWidget {
  const PhoneChange({super.key});

  @override
  State<PhoneChange> createState() => _PhoneChangeState();
}

class _PhoneChangeState extends State<PhoneChange> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? errorMsg; String? successMsg;

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    TextEditingController passwordControlller = TextEditingController();
    return isLoading ? loading() : body();
  }

  Widget loading() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 10),
            Text('လုပ်ဆောင်နေပါသည်။ ခေတ္တစောင့်ဆိုင်းပေးပါ။')
          ],
        ),
      ),
    );
  }

  Widget body(){
    return Scaffold(
      appBar: applicationBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            errorWidget(),
            successWidget(),
            formWiget('Phone Number',phoneController),
            formWiget('Accoun Password',oldPasswordController),
            actionButton(context),
          ],
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  AppBar applicationBar() {
    return AppBar(
      centerTitle: true,
      title:  Text('Phone Change',
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

  Widget errorWidget(){
    return errorMsg != null ? Container(
      color: Colors.amber,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              errorMsg!,
              style: TextStyle(),
            ),
          ),
        ]
      ),
    ) : SizedBox();
  }

  Widget successWidget(){
    return successMsg != null ? Container(
      color: Colors.cyan,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              successMsg!,
              style: TextStyle(),
            ),
          ),
        ]
      ),
    ) : SizedBox();
  }

  void goToBack() {
    Navigator.of(context).pop();
  }

  void goToHomePage(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, '/division_choice', (route) => false);
  }

  Widget formWiget(String name, TextEditingController textController,
      [hintTxt]) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          label: Text(name),
          helperText: hintTxt,
          helperStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "${name}ကို ထည့်ပါ။";
          }
        },
      ),
    );
  }

  Widget actionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              goToBack();
            },
            style: ElevatedButton.styleFrom(
                primary: Colors.black38,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7)),
            child: Text('Cancel', style: TextStyle(fontSize: 15))),
        SizedBox(
          width: 10,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                startLoading();
                changeSetting();
              }
            },
            child: Text(
              'Update',
              style: TextStyle(fontSize: 15),
            )),
      ],
    );
  }

  void changeSetting() async {
    String oldPsw = oldPasswordController.text;
    String phone = phoneController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiPath = prefs.getString("api_path");
    var token = prefs.getString('token');
    try {
      var url = Uri.parse('${apiPath}api/change_setting');
      print('apiPathi $apiPath');
      var response = await http.post(url, body: {
        'token': token,
        'old_password': oldPsw,
        'phone': phone,
      });
      Map data = jsonDecode(response.body);
      print(data);
      if (data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          prefs.setString('token', data['token']);
        });
        stopLoading();
        setState(() {
          successMsg = 'Password Updated!';
          errorMsg = null;
        });
        print(data);
      }else{
        stopLoading();
        setState(() {
          errorMsg = data['message'];
          successMsg = null;
        });
      }
    } on SocketException catch (e) {
      print('http error $e');
      stopLoading();
      showAlertDialog(
          'Connection timeout!',
          'Error occured while Communication with Server. Check your internet connection',
          context);
    } on Exception catch (e) {
      logout();
    }
  }

  void stopLoading() {
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void startLoading() {
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }

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
                child: title != 'Unauthorized' ? Text('CLOSE') : logoutButton(),
              )
            ],
          );
        });
  }

  Widget logoutButton() {
    return GestureDetector(
      child: Text('LOG OUT'),
      onTap: () {
        logout();
      },
    );
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }
}