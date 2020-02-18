import 'package:flutter/material.dart';
import '../../Views/landing_page/home_screen.dart';
import '../../Auth/auth.dart';
import '../../Views/landing_page/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  final String language;
  final AuthFunction authFunction;
  LoginScreen({this.language, this.authFunction});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final String language;
  _LoginScreenState({this.language});
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  final loginFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final resetEmail = TextEditingController();
  var _loading = false;
  var _connection;
  var _conStatus = "Unknown";
  Connectivity connectivity;
  var subscription;
  var token;

  @override
    void initState() {
      super.initState();
      _firebaseMessaging.getToken().then((id) {
        setState(() {
          token = id;
        });
      });
    _checkCon();
    }

    _checkCon() {
      connectivity = new Connectivity();
      subscription =
          connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          setState(() {
            _connection = true;
          });
        } else {
          setState(() {
            _connection = false;
            _conStatus = "No Internet Connection!";
          });
        }
      });
    }

    _accLogin() async {
      if(loginFormKey.currentState.validate()){
        if(_connection == false){
        final snackBar = SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(
            _conStatus,
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 1),
        );
        _scaffold.currentState.showSnackBar(snackBar);
        }
        else{
          setState(() {
            _loading = true;
          });
          try {
          String userId = await widget.authFunction.login(email.text, password.text);
          if(userId == "Email is not verified yet"){
            setState(() {
              _loading = false;
            });
            final snackBar = SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text(
                "Email is not verified! Please verify your email.",
                style: TextStyle(fontSize: 16.0),
              ),
              duration: Duration(seconds: 1),
            );
            _scaffold.currentState.showSnackBar(snackBar);
          }
          else{
            setState(() {
              var devID = <String, dynamic>{
                'log_in': true,
              };
              dbRef.child('user_devs').child(userId).child(token).set(devID);
              _loading = false;
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomeScreen(authFunction: Authentic(), language: language,)));
            });
          }
          } catch (e) {
            setState(() {
              _loading = false;
            });
            final snackBar = SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text(
                "Incorrect email address and password!",
                style: TextStyle(fontSize: 16.0),
              ),
              duration: Duration(seconds: 1),
            );
            _scaffold.currentState.showSnackBar(snackBar);
          }
        }
      }
    }

  
  void _routeToSignUp() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SignUpScreen(
                  language: language,
                )));
  }

  _resetEmail() {
    if(resetFormKey.currentState.validate()){
      if(_connection == false){
      final snackBar = SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          _conStatus,
          style: TextStyle(fontSize: 16.0),
        ),
        duration: Duration(seconds: 1),
      );
      _scaffold.currentState.showSnackBar(snackBar);
      }
      else{
      FirebaseAuth.instance.sendPasswordResetEmail(email: resetEmail.text);
      Navigator.pop(context);
      final snackBar = SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          "Please check your email!",
          style: TextStyle(fontSize: 16.0),
        ),
        duration: Duration(seconds: 1),
      );
      _scaffold.currentState.showSnackBar(snackBar);
      }
    }
  }

  _showForgotDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) { 
        return Form(
          key: resetFormKey,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
            ),
          title: Text("Reset Password", style: TextStyle(color: Color(0xFF666666)),),
          content: TextFormField(
            controller: resetEmail,
            validator: (value) => resetEmail.text.length <= 0 
            ? "Please Enter Email Address!" : !resetEmail.text.contains("@") 
            ? "Enter Valid Email Address." : null,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.0, horizontal: 0.0),
              labelText: "Email",
              border: UnderlineInputBorder(
              )
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: _resetEmail,
              child: Text("Reset", style: TextStyle(color: Color(0xFF666666)),),
            ),
            FlatButton(
              onPressed: () {Navigator.of(context).pop();},
              child: Text("Cancel", style: TextStyle(color: Color(0xFF666666)),),
            )
          ],
      ),
        );}
    );
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          key: _scaffold,
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "Login",
              style: TextStyle(color: Theme.of(context).textTheme.title.color),
            ),
          ),
          body:new GestureDetector(
      onTap: () {
        // call this method here to hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                        alignment: Alignment.center,
                        height: orientation == Orientation.portrait ? device.height - 24 - kToolbarHeight : device.height - 24 - kToolbarHeight + 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Image.asset('assets/images/logo.png', width: device.width/1.5,),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 32.0),
                              width: device.width - 64.0,
                              margin: EdgeInsets.only(top: 16.0),
                              child: Form(
                                key: loginFormKey,
                                  child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: email,
                                    validator: (value) => value.length == 0
                                        ? 'Email is required'
                                        : value.contains("@")
                                            ? null
                                            : 'Please enter valid email address.',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.white),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .color)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .color)),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 6.0, horizontal: 12.0),
                                        suffixIcon: Icon(Icons.email,
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                        suffixStyle: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                        labelText: 'Email',
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                        border: OutlineInputBorder()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: TextFormField(
                                    controller: password,
                                    onSaved: (value) => password.text =value,
                                      validator: (value) => value.length == 0
                                          ? 'Password is required'
                                          : null,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white),
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .title
                                                      .color)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .title
                                                      .color)),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 12.0),
                                          suffixIcon: Icon(Icons.lock,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 16.0),
                                    child: _loading == true ?
                                    Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Theme.of(context).textTheme.title.color
                                        ),
                                      ),
                                    ) : FlatButton(
                                      highlightColor: Colors.transparent,
                                      splashColor:
                                          Color.fromRGBO(0, 0, 0, 0.05),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: device.width / 8,
                                          vertical: 12.0),
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      onPressed: _accLogin,
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Don't have an account?",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                        .textTheme.title.color),
                                          ),
                                          Container(
                                            child: FlatButton(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Color.fromRGBO(
                                                  0, 0, 0, 0.05),
                                              padding: EdgeInsets.all(0.0),
                                              onPressed: _routeToSignUp,
                                              child: Text(
                                                "Sign Up",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Theme.of(context)
                                                        .textTheme.title.color),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    FlatButton(
                                      highlightColor: Colors.transparent,
                                      onPressed: _showForgotDialog,
                                      child: Text("Forgot Password ?", style: TextStyle(color: Theme.of(context).textTheme.title.color),),
                                    )
                                ],
                              )),
                            ),
                          ],
                        ),
                      ),
                  childCount: 1,
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}
