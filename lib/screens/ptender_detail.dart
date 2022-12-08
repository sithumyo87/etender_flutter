import 'dart:io';

import 'package:etender_app_1/models/ptender_model.dart';
import 'package:etender_app_1/models/tender_model.dart';
import 'package:etender_app_1/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

import 'package:url_launcher/url_launcher.dart';

class PtenderDetail extends StatefulWidget {
  const PtenderDetail({Key? key}) : super(key: key);

  @override
  State<PtenderDetail> createState() => _PtenderDetailState();
}

enum ConfirmAction { CANCEL, ACCEPT }

class _PtenderDetailState extends State<PtenderDetail> {

  File? image;
  PickedFile? pickedFile;
  final _picker = ImagePicker();

  // file picker
  File? file;

  Future<void> _pickImage(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');

    pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile!.path);
      });
    }
    // var response =
    //     await updateProfile(pickedFile, id, api_token);

    var url = Uri.parse('${apiPath}api/member_ptender_request_download/$id');
    var request = await http.MultipartRequest('POST', url);

    request.fields['apitoken'] = api_token!;

    if (pickedFile != null) {
      File file = File(pickedFile!.path);
      request.files.add(http.MultipartFile(
          'image', file.readAsBytes().asStream(), file.lengthSync(),
          filename: file.path.split('/').last));
    }

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
  }

  Future getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File resultFile = File(result.files.single.path.toString());
      setState(() {
        file = resultFile;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<http.StreamedResponse> updateProfile(
      PickedFile? data, id, api_token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${apiPath}api/member_ptender_request_download/$id/$api_token'));

    if (data != null) {
      File file = File(data.path);
      request.files.add(http.MultipartFile(
          'image', file.readAsBytes().asStream(), file.lengthSync(),
          filename: file.path.split('/').last));
    }

    var response = await request.send();
    return response;
  }

  void downloadTender(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api_token = prefs.getString('api_token');
    var apiPath = prefs.getString('api_path');
    // Uri _url = Uri.parse('${apiPath}member_ptender_download/$id/$api_token');
    // if (!await launchUrl(_url)) throw 'Could not launch $_url';
    var url = '${apiPath}member_ptender_download/$id/$api_token';
    if (await canLaunch(url))
      await launch(url);
    else
      throw "Could not launch $url";
  }

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
                child: Text('hsf'),
              )
            ],
          );
        });
  }
  // showAlertDialog function ----- end

  Widget rowData(String attr, String value) {
    return Row(
      children: [
        Text(
          attr,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget titleWidget(String state, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
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
          width: 5.0,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget body(args) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget(args.state, args.title),
              rowData('ID Number :', args.serial),
              rowData('Department :', args.department),
              SizedBox(height: 10.0),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rowData('Published Date :', args.publishedAt),
                    rowData('Closed Date :', args.closedAt),
                    SizedBox(height: 20.0),
                    Text(
                      args.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20.0),
                    Text('Cost : ${args.price} ${args.currency}',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed: () {
                        downloadTender(args.id);
                      },
                      child: Text('Download PDF', style: TextStyle(color: Colors.white),),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TenderModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paid Tenders',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: SingleChildScrollView(child: body(args)),
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
