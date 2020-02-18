import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import '../../Views/landing_page/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../Auth/auth.dart';

class SplashScreen extends StatefulWidget {
  final AuthFunction authFunction;
  SplashScreen({this.authFunction});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 1, curve: Curves.easeInOut),
    ));
    _animationController.forward();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launcher_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    startTime();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(
            authFunction: Authentic(),
          ),
        ),
      );
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(
          authFunction: Authentic(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, widget) {
                        return Image.asset(
                          'assets/images/logo.png',
                          width: (deviceWidth - 100) * _animation.value,
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24.0),
                    ),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, widget) {
                        return Text(
                          "Medical Application".toUpperCase(),
                          style: TextStyle(
                              color: Color(0xFF72bb53),
                              fontSize: 24.0 * _animation.value,
                              fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
