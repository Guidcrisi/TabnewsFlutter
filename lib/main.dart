import 'package:flutter/material.dart';
import 'package:tabnews/ui/splash-page.dart';

Future<void> main() async {
  runApp(App());
}

class App extends StatelessWidget {
  static Color primary = const Color(0xFF24292F);

  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Tabnews",
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
