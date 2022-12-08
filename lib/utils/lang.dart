import 'package:etender_app_1/Provider/LocaleProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Lang extends StatefulWidget {
  const Lang({super.key});

  @override
  State<Lang> createState() => _LangState();
}

class _LangState extends State<Lang> {
  int checkval = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: applicationBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //   child: TextButton(
            //     child: Text("မြန်မာဘာသာ"),
            //     onPressed: () => context.read<LocaleProvider>().setMyanmar(),
            //     style: ButtonStyle(
            //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10.0),

            //       )),
            //     ),
            //   ),
            // ),
            // TextButton(
            //   child: Text("English"),
            //   onPressed: () => context.read<LocaleProvider>().setEnglish(),
            // ),
            langWidget('မြန်မာဘာသာ', 0),
            langWidget('English Language', 1),
          ],
        ));
  }

  AppBar applicationBar() {
    return AppBar(
      centerTitle: true,
      title: Text(AppLocalizations.of(context)!.language,
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

  Widget langWidget(txt, check) {
    return Card(
        child: ListTile(
      title: Text(txt, style: TextStyle(fontSize: 14.0)),
      // trailing: check == checkval
      //     ? Icon(
      //         Icons.check,
      //         size: 14.0,
      //         color: Colors.black,
      //       )
      //     : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      onTap: () {
        check == 0
            ? context.read<LocaleProvider>().setMyanmar()
            : context.read<LocaleProvider>().setEnglish();
        if (check == 0) {
          setState(() {
            checkval = 0;
          });
          Navigator.pushNamedAndRemoveUntil(
        context, '/division_choice', (route) => false);
        } else if (check == 1) {
          setState(() {
            checkval = 1;
          });
          Navigator.pushNamedAndRemoveUntil(
        context, '/division_choice', (route) => false);
        }
      },
    ));
  }
}
