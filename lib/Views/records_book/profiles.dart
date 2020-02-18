import 'package:flutter/material.dart';
import 'dart:async';
import '../../Database/database.dart';
import '../../Models/records_book/record_book.dart';
import '../../Views/records_book/medrecords.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Auth/auth.dart';
import '../../Views/landing_page/login_screen.dart';
import '../../Views/landing_page/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ProfileScreen extends StatefulWidget {
  final String lan;
  final AuthFunction authFunction;
  ProfileScreen({@required this.lan, this.authFunction});
  ProfileScreenState createState() => ProfileScreenState(language: lan);
}

Future<List<User>> fetchusersFromDatabase() async {
  var dbHelper = DBHelper();
  Future<List<User>> users = dbHelper.fetchUserList();
  return users;
}

var maintheme = Color(0xFF72BB53);

// class SettingData {
//   final language;
//   SettingData(this.language);
//   static const String edit = 'Edit';
//   static const String delete = 'Delete';

//   static const List<String> languages = <String>[edit, delete];
// }

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  String notSignedIn = 'You are not signed in!';
  String login = 'Login';

  String edit;
  String delete;

  List<String> languages;
  var accID;
  var token;
  DBHelper db = DBHelper();
  var loading = true;
  Future<List<User>> fetchusersFromDatabase() async {
    var dbHelper = DBHelper();
    Future<List<User>> users = dbHelper.fetchUserList();
    setState(() {
      loading = true;
    });
    return users;
  }

  final String language;
  ProfileScreenState({@required this.language});
  var formKey = GlobalKey<FormState>();
  var formKey2 = GlobalKey<FormState>();
  var name;
  var editname;
  int count;

  Animation animation;
  AnimationController animationController;

  retrieveCount() async {
    var result = await db.getCount();
    return result;
  }

  _submit() async {
    var result = await retrieveCount();
    setState(() {
      count = result;
    });
    print(count.toString());
    if (count < 5) {
      if (this.formKey.currentState.validate()) {
        formKey.currentState.save();
        var user = User();
        user.name = name;
        await db.addUser(user);
        setState(() {
          print("User added");
        });

        return true;
      } else {
        return false;
      }
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                content: Text(language == 'en'
                      ? 'More than 5 profiles is not allowed'
                      : 'ပရိုဖိုင်များ ၅ခု ထက်မပိုရ',
                      textAlign: TextAlign.center,
                      ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(language == 'en' ? 'Close' : 'ပိတ်မယ်'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    }
  }

  void _update(int id) {
    if (this.formKey2.currentState.validate()) {
      formKey2.currentState.save();
      var dbhelper = DBHelper();
      var user = User();
      user.id = id;
      user.name = editname;
      dbhelper.updateUser(user);
      print("User updated");
    }
  }

  @override
  void initState() {
    _setLanguage(language);
    widget.authFunction.getUser().then((user) {
      if (user == null) {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      } else if (user == "Not Verified User") {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      } else {
        setState(() {
          accID = user;
          authStatus = AuthStatus.signedIn;
        });
      }
    });
    _firebaseMessaging.getToken().then((id) {
      setState(() {
        token = id;
      });
    });
    super.initState();
    if (language == "en") {
      edit = 'Edit';
      delete = 'Delete';
      languages = <String>[edit, delete];
    } else {
      edit = 'ပြင်မည်';
      delete = 'ဖျက်မည်';
      languages = <String>[edit, delete];
    }
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();
  }

  _setLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        notSignedIn = 'အကောင့်မဝင်ထားပါ';
        login = 'အကောင့်ဝင်ရန်';
      });
    }
  }

  Future<bool> _backToMain() {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(
                  authFunction: Authentic(),
                  language: language,
                )));
  }

  _logout() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Log Out",
              style: TextStyle(color: Color(0xFF333333)),
            ),
            content: Text("Are you sure to log out?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 18.0)),
                onPressed: () {
                  widget.authFunction.signOut();
                  Navigator.of(context).pop();
                  setState(() {
                    var devID = <String, dynamic>{
                      'log_in': false,
                    };
                    dbRef
                        .child('user_devs')
                        .child(accID)
                        .child(token)
                        .set(devID);
                    authStatus = AuthStatus.notSignedIn;
                  });
                },
              ),
              FlatButton(
                child: Text("No",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 18.0)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return WillPopScope(
          onWillPop: _backToMain,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                language: language,
                                authFunction: Authentic(),
                              )));
                },
              ),
              iconTheme: Theme.of(context).iconTheme,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      notSignedIn,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                    authFunction: Authentic(),
                                    language: language,
                                  )));
                    },
                    child: Text(
                      login,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.title.color),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      case AuthStatus.signedIn:
        return Scaffold(
          appBar: AppBar(
            title: Text(
              language == 'en' ? 'PROFILES' : 'ပရိုဖိုင်များ',
              style: TextStyle(color: Theme.of(context).textTheme.title.color),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                              language: language,
                              authFunction: Authentic(),
                            )));
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  size: 32.0,
                ),
                onPressed: _logout,
              )
            ],
            iconTheme: Theme.of(context).iconTheme,
            backgroundColor: maintheme,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: maintheme,
            tooltip: 'Create Profile',
            child: Icon(
              Icons.person_add,
              size: 32.0,
            ),
            onPressed: _createProfile,
          ),
          body: _profileBody(),
        );
    }
  }

  void _createProfile() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Container(
            height: 59.0,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              title: Text(
                language == 'en' ? 'Create Profile' : 'ပရိုဖိုင်းဖန်တီးပါ',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              content: Container(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: language == 'en'
                            ? 'Profile Name'
                            : 'ပရိုဖိုင်းအမည်'),
                    validator: (val) => val.isEmpty
                        ? language == 'en'
                            ? "Profile name is required"
                            : 'ပရိုဖိုင်းအမည်လိုအပ်ပါသည်'
                        : null,
                    onSaved: (val) => this.name = val,
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  highlightColor: Colors.transparent,
                  splashColor: Color.fromRGBO(114, 187, 83, 0.15),
                  child: Text(
                    language == 'en' ? 'Cancel' : 'ရုပ်သိမ်း',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  splashColor: Color.fromRGBO(114, 187, 83, 0.15),
                  highlightColor: Colors.transparent,
                  child: Text(
                    language == 'en' ? 'CREATE' : 'ဖန်တီး',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    bool boolean = await _submit();
                    setState(() {
                      if (boolean == true) {
                        Navigator.pop(context);
                      }
                    });
                  },
                )
              ],
            ),
          );
        });
  }

  _profileBody() {
    return Container(
      child: new FutureBuilder<List<User>>(
        future: fetchusersFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length != 0) {
            return AnimatedBuilder(
                animation: animationController,
                builder: (BuildContext context, Widget widget) =>
                    ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Transform(
                              transform: Matrix4.translationValues(
                                  animation.value *
                                      MediaQuery.of(context).size.width,
                                  0.0,
                                  0.0),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 6.0,
                                    bottom: 4.0,
                                    left: 12.0,
                                    right: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => MedRec(
                                                  id: snapshot.data[index].id,
                                                  lan: language,
                                                )));
                                  },
                                  child: Container(
                                    width: 250.0,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        border: Border.all(
                                            color: Color(0xFF72BB53))),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 16.0),
                                          alignment: Alignment.centerLeft,
                                          child: Text(snapshot.data[index].name,
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black)),
                                        ),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Color(0xFF72BB53),
                                              size: 30.0,
                                            ),
                                            itemBuilder:
                                                (BuildContext context) {
                                              return languages
                                                  .map((String func) {
                                                return PopupMenuItem<String>(
                                                  value: func,
                                                  child: Text(func),
                                                );
                                              }).toList();
                                            },
                                            onSelected: (String choice) {
                                              if (choice == "Edit" ||
                                                  choice == "ပြင်မည်") {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext
                                                                context) =>
                                                            Container(
                                                              child:
                                                                  AlertDialog(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16.0)),
                                                                title: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .person,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                    ),
                                                                    Text(
                                                                      snapshot
                                                                          .data[
                                                                              index]
                                                                          .name,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Theme.of(context).primaryColor),
                                                                    ),
                                                                  ],
                                                                ),
                                                                content:
                                                                    Container(
                                                                  child: Form(
                                                                    key:
                                                                        formKey2,
                                                                    child:
                                                                        TextFormField(
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .text,
                                                                      decoration:
                                                                          InputDecoration(
                                                                              labelText: 'Profile Name'),
                                                                      validator: (val) => val.length ==
                                                                              0
                                                                          ? "Profile name is required"
                                                                          : null,
                                                                      autofocus:
                                                                          true,
                                                                      initialValue: snapshot
                                                                          .data[
                                                                              index]
                                                                          .name,
                                                                      onSaved: (val) =>
                                                                          this.editname =
                                                                              val,
                                                                    ),
                                                                  ),
                                                                ),
                                                                actions: <
                                                                    Widget>[
                                                                  FlatButton(
                                                                    splashColor:
                                                                        Color.fromRGBO(
                                                                            114,
                                                                            187,
                                                                            83,
                                                                            0.15),
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Text(
                                                                      language ==
                                                                              'en'
                                                                          ? 'Cancel'
                                                                          : "ရုပ်သိမ်း",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Theme.of(context).primaryColor),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                  FlatButton(
                                                                    splashColor:
                                                                        Color.fromRGBO(
                                                                            114,
                                                                            187,
                                                                            83,
                                                                            0.15),
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: Text(
                                                                        language ==
                                                                                'en'
                                                                            ? 'Confirm'
                                                                            : 'အတည်ပြု',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).primaryColor)),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        _update(snapshot
                                                                            .data[index]
                                                                            .id);
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            ));
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        Container(
                                                          child: AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0)),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                child: Text(
                                                                    language ==
                                                                            'en'
                                                                        ? 'Cancel'
                                                                        : "ရုပ်သိမ်း"),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                              FlatButton(
                                                                textColor:
                                                                    Colors.red,
                                                                splashColor: Color
                                                                    .fromRGBO(
                                                                        114,
                                                                        187,
                                                                        83,
                                                                        0.15),
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                child: Text(
                                                                  language ==
                                                                          'en'
                                                                      ? 'Delete'
                                                                      : "ဖျက်မည်",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                onPressed: () {
                                                                  DBHelper dh =
                                                                      new DBHelper();
                                                                  setState(() {
                                                                    dh.deleteUser(
                                                                        snapshot
                                                                            .data[index]
                                                                            .id);
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              )
                                                            ],
                                                            content: language ==
                                                                      'en'
                                                                  ? Text(
                                                                      'Do you want to delete this profile?',
                                                                      textAlign: TextAlign.center,  
                                                                    )
                                                                  : Text(
                                                                      'ဤပရိုဖိုင်းကိုဖျက်ရန်လိုပါသလား?',
                                                                      textAlign: TextAlign.center, 
                                                                    ),

                                                          ),
                                                        ));
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                        }));
          } else {
            return Center(
                child: Container(
              child:
                  Text(language == 'en' ? "No Profiles" : 'ပရိုဖိုင်များမရှိပါ',
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
            ));
          }
        },
      ),
    );
  }
}
