import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';

class SignUpScreen extends StatefulWidget {
  final String language;
  SignUpScreen({this.language});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final String language;
  _SignUpScreenState({this.language});
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  var _loading = false;
  final signUpFormKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  var _connection;
  var _conStatus = "Unknown";
  Connectivity connectivity;
  var subscription;

  @override
  void initState() {
    super.initState();
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

  _signUp() async {
    if (signUpFormKey.currentState.validate()) {
      if (_connection == false) {
        final snackBar = SnackBar(
          backgroundColor: Color(0xFFFFFFFF),
          content: Text(
            _conStatus,
            style: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
          ),
          duration: Duration(seconds: 1),
        );
        _scaffold.currentState.showSnackBar(snackBar);
      } else {
        setState(() {
          _loading = true;
        });
        try {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: email.text, password: password.text)
              .then((account) {
            account.sendEmailVerification();
          });
          setState(() {
            _loading = false;
          });
          Navigator.pop(context);
        } catch (e) {
          setState(() {
            _loading = false;
          });
          final snackBar = SnackBar(
            backgroundColor: Color(0xFFFFFFFF),
            content: Text(
              e.toString().substring(29, e.toString().lastIndexOf(",")) ==
                      "The email address is already in use by another account."
                  ? "Email is already signed up."
                  : "Something Wrong.",
              style: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
            ),
            duration: Duration(seconds: 1),
          );
          _scaffold.currentState.showSnackBar(snackBar);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          key: _scaffold,
          body: new GestureDetector(
      onTap: () {
        // call this method here to hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    child: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              iconTheme: Theme.of(context).iconTheme,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                        padding: orientation == Orientation.portrait
                            ? null
                            : EdgeInsets.only(bottom: 32.0),
                        alignment: Alignment.center,
                        color: Theme.of(context).primaryColor,
                        height: orientation == Orientation.portrait
                            ? device.height - 24.0 - kToolbarHeight
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: orientation == Orientation.landscape
                                  ? EdgeInsets.only(top: 32.0)
                                  : EdgeInsets.all(0.0),
                              padding: EdgeInsets.all(8.0),
                              child: Image.asset(
                                "assets/images/logo.png",
                                width: orientation == Orientation.portrait
                                    ? device.width / 2
                                    : device.width / 3,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xFFFFFFFF),
                              ),
                              padding: EdgeInsets.all(16.0),
                              width: device.width - 64.0,
                              margin: EdgeInsets.only(top: 16.0),
                              child: Form(
                                  key: signUpFormKey,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        validator: (value) => value.length == 0
                                            ? 'Email is required'
                                            : value.contains("@")
                                                ? null
                                                : 'Please enter valid email address.',
                                        controller: email,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black54),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 6.0,
                                                    horizontal: 12.0),
                                            suffixIcon: Icon(Icons.email),
                                            labelText: 'Email',
                                            border: UnderlineInputBorder(
                                                borderSide:
                                                    BorderSide(width: 1.0))),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: TextFormField(
                                          controller: password,
                                          validator: (value) => value.length ==
                                                  0
                                              ? 'Password is required'
                                              : value.length <= 4
                                                  ? 'Password must be more than 5'
                                                  : null,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black54),
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 12.0),
                                              suffixIcon: Icon(Icons.lock),
                                              labelText: 'Password',
                                              border: UnderlineInputBorder(
                                                  borderSide:
                                                      BorderSide(width: 1.0))),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 16.0),
                                        child: _loading == true
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ),
                                              )
                                            : FlatButton(
                                                highlightColor:
                                                    Colors.transparent,
                                                splashColor: Color.fromRGBO(
                                                    0, 0, 0, 0.05),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 75.0,
                                                    vertical: 12.0),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),
                                                onPressed: _signUp,
                                                child: Text(
                                                  "Sign Up",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .title
                                                          .color),
                                                ),
                                              ),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                  childCount: 1),
            ),
          ]),
        ),
        );
      },
    );
  }
}
