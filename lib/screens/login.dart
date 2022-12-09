import 'package:etender_app_1/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  
  bool isLoading = true;

  final _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String fcmKey = ''; String? apiPath;

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

    print('apiPaht $apiPath');
    
    String fcm_key = prefs.getString('fcm_key').toString();
    setState(() {
      fcmKey = fcm_key;
    });

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
          setState(() {
            isLoading = false;
          });
          // RestartWidget.restartApp(context);
          Navigator.pushReplacementNamed(context, '/ftender');
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Expection $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  final logo = Hero(
      tag: 'hero',
      child: Image.asset(
        'assets/images/logo.png',
        width: 100,
        height: 100,
      ));

  final slogam = const Center(
    child: Text(
      'Login to Etender',
      style: TextStyle(
        fontSize: 18,
        color: Colors.blue,
      ),
    ),
  );

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

  // login function ----- start
  void login(BuildContext context, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');

    print('login into $apiPath');

    if(apiPath != ''){
      try {
        var url = Uri.parse('${apiPath}api/member_login');
        // print('${apiPath}api/member_login');
        var response = await http.post(url, body: {
          'email': email,
          'password': password,
          'fcm_key': fcmKey,
        });
        Map data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            isLoading = false;
          });
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {
            print(data['api_token']);
            prefs.setString('api_token', data['api_token']);
            prefs.setString('user_email', email);
          });
          Navigator.pushReplacementNamed(context, '/ftender');
        } else {
          setState(() {
            isLoading = false;
          });
          showAlertDialog('Login Invalid!', data['error'].toString(), context);
        }
        // print('Response status: ${response.statusCode}');
        // print('Response body: ${response.body}');
      } catch (e) {

        print(e);
        setState(() {
          isLoading = false;
        });
        showAlertDialog('Connection Failed!',
            'Please check your internet connection.', context);
      }

    }
  }
  // login function ----- end

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

  void createLink() async {
    await Navigator.pushNamed(context, '/register');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var api_token = prefs.getString('api_token');
    // var apiPath = prefs.getString('api_path');

    // var url = '${apiPath}member/register';
    // if (await canLaunch(url))
    //   await launch(url);
    // else
    //   throw "Could not launch $url";
  }

  void resetLink() async {
    await Navigator.pushNamed(context, '/reset_password');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var api_token = prefs.getString('api_token');
    // var apiPath = prefs.getString('api_path');

    // var url = '${apiPath}member/password/reset';
    // if (await canLaunch(url))
    //   await launch(url);
    // else
    //   throw "Could not launch $url";
  }

  @override
  Widget build(BuildContext context) {

    // username input field ------ start
    final username = TextFormField(
      controller: emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter email";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Email',
      ),
    );
    // username input field ------ start

    // password input field  ------ start
    final password = TextFormField(
      controller: passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter password";
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Password'),
    );
    // password input field  ------ end

    final loginButton = ElevatedButton(
      onPressed: () {
        if (_loginFormKey.currentState!.validate()) {
          setState(() {
            isLoading = true;
          });
          initializePrefs();
          login(context, emailController.text, passwordController.text);
        }
      },
      child: const Text(
        'Log In',
        style: TextStyle(fontSize: 16),
      ),
    );

    final createAccount = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13.0,
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        GestureDetector(
          onTap: () {
            createLink();
          },
          child: Text(
            'Sign Up Now',
            style: TextStyle(
              color: Colors.lightBlue,
              fontSize: 13.0,
            ),
          ),
        ),
      ],
    );

    final forgotPassword = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Forgot Your Password?',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13.0,
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        GestureDetector(
          onTap: () {
            resetLink();
          },
          child: Text(
            'Reset Password',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 13.0,
            ),
          ),
        ),
      ],
    );

    Widget body() {
      return Container(
        child: Form(
            key: _loginFormKey,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(20.0),
                children: <Widget>[
                  logo,
                  SizedBox(height: 10.0),
                  slogam,
                  SizedBox(height: 10.0),
                  username,
                  SizedBox(height: 10.0),
                  password,
                  SizedBox(height: 20.0),
                  loginButton,
                  SizedBox(height: 20.0),
                  createAccount,
                  SizedBox(height: 5.0),
                  forgotPassword,
                ],
              ),
            )),
      );
    }

    return Scaffold(
      body: isLoading ? loading() : body(),
    );
  }
}
