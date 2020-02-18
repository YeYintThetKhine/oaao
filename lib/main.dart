import 'package:flutter/material.dart';
import 'Views/splash_screen/splash_screen.dart';
import 'Views/landing_page/home_screen.dart';
import 'Views/notification/reminder.dart';
import 'Views/landing_page/signup_screen.dart';
import 'Views/landing_page/login_screen.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color(0xFF72bb53),
          textTheme: TextTheme(
              title: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20.0)),
          iconTheme: IconThemeData(color: Color(0xFFFFFFFF))),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/LoginScreen': (BuildContext context) => LoginScreen(),
        '/SignUpScreen': (BuildContext context) => SignUpScreen(),
        '/HomeScreen': (BuildContext context) => HomeScreen(),
        '/ReminderList': (BuildContext context) => ReminderList(),
      },
    ));
