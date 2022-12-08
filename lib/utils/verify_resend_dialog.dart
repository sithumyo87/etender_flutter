import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VerifyResendDialog extends StatefulWidget {
  final String title;
  final String content;
  final String email;
  final String password;
  const VerifyResendDialog(this.title, this.content, this.email, this.password);

  @override
  _VerifyResendDialogState createState() => new _VerifyResendDialogState();
}

class _VerifyResendDialogState extends State<VerifyResendDialog> {
  String? title;
  String? content;
  String? email;
  String? password;
  bool isSend = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    setState(() {
      title = title ?? widget.title;
      content = content ?? widget.content;
      email = email ?? widget.email;
      password = password ?? widget.password;
    });
    return isLoading ? loading() : AlertDialog(
      title: Text(title!),
      content: Text(content!),
      actions: <Widget>[
        !isSend && !isLoading
            ? MaterialButton(
                color: Colors.red,
                onPressed: () {
                  if (!isSend) {
                    startLoading();
                    resendVerify(context, email!, password!);
                  }
                },
                child: Text(
                  'Resend Verify',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : SizedBox(),
        !isLoading
            ? MaterialButton(
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'CLOSE',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : SizedBox(),
      ],
    );
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

  void resendVerify(BuildContext context, String email, String password) async {
    setState(() {
      isSend = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiPath = prefs.getString("api_path");
    try {
      var url = Uri.parse('${apiPath}api/resend_verify45xGW0uEXlu');
      var response = await http.post(url, body: {
        'email': email,
        'password': password,
      });
      Map data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          title = data['title'];
          content = data['message'];
        });
        stopLoading();
      } else {
        setState(() {
          title = data['title'];
          content = data['message'];
        });
        stopLoading();
      }
    } on SocketException catch (e) {
      setState(() {
        isSend = false;
        title = 'Connection timeout!';
        content =
            'Error occured while Communication with Server. Check your internet connection';
      });
    }
  }

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }
}
