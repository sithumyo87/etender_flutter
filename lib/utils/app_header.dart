import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String slogam = 'assets/images/logo.png';
  final String app_name = 'Etender App';
  final String header_title;
  final String login_user;
  const AppHeader(this.header_title, this.login_user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      child: Row(
        children: [
          Image.asset(
            slogam,
            width: 50.0,
            height: 50.0,
          ),
          SizedBox(
            width: 10.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                app_name,
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 20.0,
                ),
              ),
              Text(
                header_title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
              // Flexible(
              //   child: Text(
              //     'LOG-IN as $login_user',
              //     overflow: TextOverflow.ellipsis,
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 14.0,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
      ),
    );
  }
}
