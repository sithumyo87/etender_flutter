import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EmailChange extends StatefulWidget {
  const EmailChange({super.key});

  @override
  State<EmailChange> createState() => _EmailChangeState();
}

class _EmailChangeState extends State<EmailChange> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? errorMsg = 'အီးမေးလ် ပြောင်းလဲခြင်းအောင်မြင်ပါက logout ထွက်သွားပါလိမ့်မည်။ ပြောင်းလဲလိုက်သော အီးမေးလ်အသစ်တွင် Verify လုပ်ပေးရန်လိုအပ်ပါသည်။ '; 
  String? successMsg;

  @override
  Widget build(BuildContext context) {
     return isLoading ? loading() : body();
  }

  AppBar applicationBar() {
    return AppBar(
      centerTitle: true,
      title: const Text("အီးမေးလ်အကောင့်ပြင်ဆင်ခြင်း",
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
  Widget body(){
    return WillPopScope(
      child: Scaffold(
        appBar: applicationBar(),
        body:  Form(
          key: _formKey,
          child: Column(
            children: [
              errorWidget(),
              successWidget(),
              formWiget(AppLocalizations.of(context)!.email_new_add,emailController),
              formWiget(AppLocalizations.of(context)!.password,oldPasswordController,"ယခုအီးမေးလ်လိပ်စာ၏စကားဝှက်ကိုဖြည့်သွင်းရမည်",true),
              actionButton(context),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        goToBack();
        return true;
      },
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
      [hintTxt,checkps=false]) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextFormField(
        controller: textController,
        obscureText: checkps,
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
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(fontSize: 15))),
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
                _formKey.currentState?.reset();
                  emailController.clear();
                  oldPasswordController.clear();
              }
            },
            child: Text(
              AppLocalizations.of(context)!.update,
              style: TextStyle(fontSize: 15),
            )),
      ],
    );
  }

  void changeSetting() async {
    String oldPsw = oldPasswordController.text;
    String email = emailController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiPath = prefs.getString("api_path");
    var token = prefs.getString('token');
    try {
      var url = Uri.parse('${apiPath}api/change_setting');
      print('apiPathi $apiPath');
      var response = await http.post(url, body: {
        'token': token,
        'old_password': oldPsw,
        'email': email,
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
          successMsg =  AppLocalizations.of(context)!.email_change_upd;
          errorMsg = null;
        });
        logout();
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