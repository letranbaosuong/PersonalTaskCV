import 'package:flutter/material.dart';
import 'package:flutter_personal_taskcv_app/src/services/authentication.dart';
import 'package:flutter_personal_taskcv_app/src/views/screens/root_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal TaskCV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.orange,
        cursorColor: Colors.orange,
        textTheme: TextTheme(
          headline1: GoogleFonts.openSans(
            fontSize: 45,
            color: Colors.orange,
          ),
          button: GoogleFonts.openSans(),
          subtitle1: GoogleFonts.notoSans(),
          bodyText1: GoogleFonts.notoSans(),
        ),
      ),
      home: RootScreen(
        auth: Auth(),
      ),
    );
  }
}
