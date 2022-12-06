import 'dart:async';

import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:tabnews/data/store_secure_user.dart';
import 'package:tabnews/main.dart';
import 'package:tabnews/ui/home-page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    StoreSecureUser.readData("darkMode").then((value) {
      setState(() {
        if (value == "1") {
          darkMode = true;
        } else {
          darkMode = false;
        }
      });
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? App.primary : Colors.white,
      body: Center(
        child: Entry.offset(
            child: Image(
          image: AssetImage(
              darkMode ? "img/tabnews-white-logo.png" : "img/tabnews-logo.png"),
          width: 250,
        )),
      ),
    );
  }
}
