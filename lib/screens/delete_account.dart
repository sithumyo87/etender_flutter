import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:etender_app_1/utils/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {

  bool isLoading = false;
  bool isError = false; String? errorMsg;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  Container notiText = Container(
                padding: EdgeInsets.all(
                  15.0
                ),
                color: Colors.amberAccent,
                child: Text(
                  'NOTICE: Your account will be deleted from the system. This action can\'t be undoned. Once you deleted your account, you\'re not able to login with your account on both website and mobile application. If you\'re sure to delete your account, enter your password and click "Delete Account" button.',
                  style: TextStyle(
                    fontSize: 15.0
                  ),
                ),
              );


  ButtonTheme deleteButton() => ButtonTheme(
                minWidth: 100.0,
                child: TextButton(
                  style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                              textStyle: MaterialStateProperty.all(
                                TextStyle(color: Colors.white),
                              ),
                            ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      deleteAccountAction();
                    }else{
                      print('error');
                    }
                    
                  },
                ),
              );

  
  TextFormField password() =>  TextFormField(
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter password";
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Account Password'),
    );


  // loading widget ----- start
  Widget body() {
    return Form(
      key: _formKey,
      child: Container(
          child: Stack(children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(children: [
                notiText,
                SizedBox(height: 10.0),
                password(),
                SizedBox(height: 10.0,),
                isError ? errorWid() : SizedBox(),
                SizedBox(height: 10.0,),
                deleteButton(),
                SizedBox(height: 10.0),
              ]),
            ),
          ]),
        ),
    );
  }
  // loading widget ----- end

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Free Tenders',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: isLoading ? loading() : body(),
      drawer: AppDrawer(),
    );
  }

  // loading widget ----- start
  Widget loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  // loading widget ----- end

  // body widget ----- start
  Widget errorWid() {
    return Center(
      child: Text(errorMsg ?? '', style: TextStyle(
        color: Colors.red
      ),),
    );
  }
  // body widget ----- end

  // getting ftenders data ----- start
  void deleteAccountAction() async {
    print('deleteing accout');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');
    try {
      var url = Uri.parse('${apiPath}api/delete_account');
      var response = await http.post(url, body: {
        'apitoken': api_token,
        'password': _passwordController.text
      });
      print('url $url');
      print('apitoken $api_token');
      print('password ${_passwordController.text}');
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success']) {
        print('success');
        print(data);
        logout();
      } else {
        print('falid');
        setState(() {
          isError = true;
          errorMsg = data['errorMsg'];
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('error');
      setState(() {
        isLoading = false;
      });
      // logout();
      print(e);
    }
  }
  // getting ftenders data ----- end

  void logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('api_token');
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  
}