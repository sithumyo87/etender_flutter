import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

import '../../utils/verify_resend_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();

  String? nameError, emailError, phoneError, passwordError;

  @override
  Widget build(BuildContext context) {
    return isLoading ? loading() : Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.register,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body:  body(context),
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

  Widget errorText(String? text) {
    return Text(text ?? '',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.0,
        ));
  }

  Widget body(context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              nameField(),
              nameError != null ? errorText(nameError) : SizedBox(),
              emailField(),
              emailError != null ? errorText(emailError) : SizedBox(),
              phoneField(),
              phoneError != null ? errorText(phoneError) : SizedBox(),
              passwordField(),
              passwordError != null ? errorText(passwordError) : SizedBox(),
              confPswField(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  errorClear();
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    initializePrefs();
                    register(context);
                  }
                },
                child: const Text(
                  "အကောင့်ပြုလုပ်မည်",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nameField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: TextFormField(
        controller: nameController,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.name,
          helperStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.name;
          } else if (value.length > 100) {
            return "နာမည်စာလုံးအရေအတွက်မှာ အလုံး ၁၀၀ ထပ်မပိုရပါ။";
          }
          return null;
        },
      ),
    );
  }

  Widget emailField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: TextFormField(
        controller: emailController,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.email,
          helperStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.email;
          } else if (!EmailValidator.validate(value)) {
            return AppLocalizations.of(context)!.email_check;
          }
          return null;
        },
      ),
    );
  }

  Widget passwordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: TextFormField(
        controller: passwordController,
        enableSuggestions: false,
        obscureText: true,
        autocorrect: false,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          labelText:  AppLocalizations.of(context)!.password,
          helperStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.password;
          } else if (value.length > 20) {
            return "စကားဝှက်အရေအတွက်မှာ အလုံး ၂၀ ထပ်မပိုရပါ။";
          }
          return null;
        },
      ),
    );
  }

  Widget confPswField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: TextFormField(
        controller: confPasswordController,
        enableSuggestions: false,
        obscureText: true,
        autocorrect: false,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.confirm_password,
          helperStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.confirm_password_add;
          } else if (value != passwordController.text) {
            return "စကားဝှက်နှင့် ကိုက်ညီမှုမရှိပါ။";
          }
          return null;
        },
      ),
    );
  }

  Widget phoneField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: TextFormField(
        controller: phoneController,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.phone_msg,
          helperStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return  AppLocalizations.of(context)!.phone;
          } else if (value.length < 9 || value.length > 11) {
            return "ဖုန်းနံပါတ်စာလုံးအရေအတွက်မှာ ၉လုံးမှ ၁၁ လုံးအတွင်းဖြစ်ရပါမည်။";
          }
          return null;
        },
      ),
    );
  }

  initializePrefs() async {
    // String apiPath = "http://192.168.99.134/eform/public/";
    // String apiPath = "http://192.168.99.248/eform/public/";
    String apiPath = "http://192.168.99.220/eform/public/";

    try{
      // for production
      var url =
          Uri.parse('https://eform.moee.gov.mm/api/etender_xOmfnoG1N7Nxgv');
      var response = await http.post(url, body: {});
      Map data = jsonDecode(response.body);
      print(data);

      if (data['success'] == true) {
        apiPath = data['path'];
      } else {
        apiPath = 'https://etender.moee.gov.mm/';
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString('api_path', apiPath);
      });
    } catch(e){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString('api_path', 'https://ettest.moee.gov.mm/');
      });
    }
  }

  void register(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiPath = prefs.getString("api_path");
    try {
      var url = Uri.parse('${apiPath}api/registerxnf8sdb^&sdf5nonv');
      print('apiPathi $apiPath');
      var response = await http.post(url, body: {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        // 'company_regno': regController.text,
      });
      Map data = jsonDecode(response.body);
      if (data['success'] == true) {
        stopLoading();
        inputClear();
        errorClear();
        showVerifyDialog(data['title'], data['message'], context);
      } else {
        stopLoading();
        if (data['title'] == 'Validate Error') {
          Map errors = data['errors'];
          print('errors $errors');
          if (errors['name'] != null) {
            nameError = errors['name'].toString();
          } else {
            nameError = null;
          }
          if (errors['email'] != null) {
            emailError = errors['email'].toString();
          } else {
            emailError = null;
          }
          if (errors['phone'] != null) {
            phoneError = errors['phone'].toString();
          } else {
            phoneError = null;
          }
          if (errors['password'] != null) {
            passwordError = errors['password'].toString();
          } else {
            passwordError = null;
          }
        } else {
          showAlertDialog(data['title'], data['message'], context);
        }
      }
    } on SocketException catch (e) {
      print('http error $e');
      stopLoading();
      showAlertDialog(
          'Connection timeout!',
          'Error occured while Communication with Server. Check your internet connection',
          context);
    }
  }

  void inputClear() {
    setState(() {
      nameController.text = '';
      emailController.text = '';
      phoneController.text = '';
      passwordController.text = '';
      confPasswordController.text = '';
    });
  }

  void errorClear() {
    setState(() {
      nameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
    });
  }

  void showVerifyDialog(String title, String content, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return VerifyResendDialog(
              title, content, emailController.text, passwordController.text);
        });
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
