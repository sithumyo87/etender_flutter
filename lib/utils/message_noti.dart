import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MessageNoti extends StatefulWidget {
  const MessageNoti({Key? key}) : super(key: key);

  @override
  State<MessageNoti> createState() => _MessageNotiState();
}

class _MessageNotiState extends State<MessageNoti> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
     return isLoading ? loading() : Scaffold(
      body:  body(),
    );
  }

   Widget body(){
    return WillPopScope(
      child: Scaffold(
        appBar: applicationBar(),
        body:  Form(
          child: Column(
            children: [
              notiWidget(context),
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

   Widget notiWidget(context){
   var msize = MediaQuery.of(context).size;
   return Column(
     children: [
       Container(
          width: msize.width,
          height: 65,
          child: InkWell(
            onTap: (){
               Navigator.pushNamed(
        context, '/message_detail');
            },
            child: Card(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(Icons.message,color: Colors.black54,),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          "ငွေသွင်းရန် အကြောင်းကြားစာ", textAlign: TextAlign.left,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),
                        ),
                         Text(
                          "20-7-2022", textAlign: TextAlign.left,style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        InkWell(
           onTap: (){
               Navigator.pushNamed(
        context, '/message_detail');
            },
          child: Card(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(Icons.message,color: Colors.black54,),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        "ငွေသွင်းရန် အကြောင်းကြားစာ", textAlign: TextAlign.left,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),
                      ),
                       Text(
                        "20-7-2022", textAlign: TextAlign.left,style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal,),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
     ],
   );
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
 

  void goToBack() {
    Navigator.of(context).pop();
  }

  void goToHomePage(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, '/division_choice', (route) => false);
  }
}