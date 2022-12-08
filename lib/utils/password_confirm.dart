import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PasswordConfirm extends StatefulWidget {
  const PasswordConfirm({super.key});

  @override
  State<PasswordConfirm> createState() => _PasswordConfirmState();
}

class _PasswordConfirmState extends State<PasswordConfirm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool confirmError = false;
  bool isLoading = false;

  String? errorMsg; String? successMsg;

  Widget build(BuildContext context) {
    return isLoading ? loading() : Scaffold(
      body:  body(),
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

  Widget body(){
    return Scaffold(
      appBar: applicationBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            errorWidget(),
            successWidget(),
            formWiget(AppLocalizations.of(context)!.add_old_password,oldPasswordController, 'oldPsw'),
            formWiget(AppLocalizations.of(context)!.add_new_password,newPasswordController, 'newPsw'),
            formWiget(AppLocalizations.of(context)!.confirm_password,confirmPasswordController, 'confPsw'),
            actionButton(context),
          ],
        ),
      )
    );
  }

  AppBar applicationBar() {
    return AppBar(
      centerTitle: true,
      title:  Text( AppLocalizations.of(context)!.change_password,
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
      formName, [hintTxt]) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextFormField(
        obscureText: true,
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
          }else{
            if(formName == 'confPsw'){
              if(value != newPasswordController.text){
                return "${name}မှားနေပါသည်။";
              }
            }
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
                  newPasswordController.clear();
                  oldPasswordController.clear();
                confirmPasswordController.clear();
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
    String newPsw = newPasswordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiPath = prefs.getString("api_path");
    var token = prefs.getString('token');
    try {
      var url = Uri.parse('${apiPath}api/change_setting');
      print('apiPathi $apiPath');
      var response = await http.post(url, body: {
        'token': token,
        'old_password': oldPsw,
        'new_password': newPsw,
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
          successMsg = AppLocalizations.of(context)!.password_change_upd;
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

  void goToNextPage(){
    Navigator.pushNamed(context, '/password_change');
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