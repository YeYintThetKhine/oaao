import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import '../../Animations/slide_right_in.dart';
import '../../Animations/slide_up_in.dart';
import '../../Views/doctor/doctor_type_list.dart';
import '../../Views/medicine/medicine_list.dart';
import '../../Views/knowledge/knowledge_main.dart';
import '../../Views/hospital/hospital_n.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Models/landing_page/news.dart';
import '../../Views/notification/reminder.dart';
import '../../Views/news/news.dart';
import '../../Views/news/news_list.dart';
import '../../Views/ask_chat/chat_room.dart';
import '../../Database/database.dart';
import '../../Models/notification/reminder.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../Views/records_book/profiles.dart';
import '../../Auth/auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity/connectivity.dart';

class MenuSetting {
  static const String myanmar = 'Myanmar';
  static const String english = 'English';

  static const List<String> languages = <String>[english, myanmar];
}

Future<List<Reminder>> reminderData() async {
  var dbHelper = DBHelper();
  Future<List<Reminder>> reminders = dbHelper.getReminderList();
  return reminders;
}

class HomeScreen extends StatefulWidget {
  final String language;
  final AuthFunction authFunction;
  HomeScreen({this.language, this.authFunction});
  @override
  _HomeScreenState createState() => _HomeScreenState(setLan: language);
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  final String setLan;
  _HomeScreenState({this.setLan});
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  Animation animation, logoAnimation, menuAnimation;
  AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _isLoading = false;
  News news;
  List<News> newsList = [];
  List<String> menuName = [
    'Records Book',
    'Doctors',
    'Hospitals',
    'Medicines',
    'Knowledge',
    'Ask & Chat'
  ];
  List<String> menuIcon = [
    'assets/icons/record_book.png',
    'assets/icons/doctor.png',
    'assets/icons/hospital.png',
    'assets/icons/medicine.png',
    'assets/icons/knowledge.png',
    'assets/icons/ask_chat.png'
  ];

  String menuNews = "News";
  String language = "en";
  double dynSize = 16.0;
  List<Reminder> reminderList = [];
  List<Reminder> appointList = [];
  var reminderTitle = 'No Reminder';
  var reminderTime = '';
  var appointTitle = 'No Appointment';
  var appointTime = '';
  var appointShowDate = '';
  var reminderShowDate = '';
  var scheduleDate = DateFormat("yyyy-MM-dd H:mm");
  var monthFormat = DateFormat("MMM");
  var dateFormat = DateFormat("dd");
  var newsData = 'No News';
  var _viewAll = 'View All';
  var loggedIn = false;
  var account = '';
  var _connection;
  var _conStatus = "Unknown";
  Connectivity connectivity;
  var subscription;

  _getNews() {
    dbRef.child('news').once().then((DataSnapshot dataSnap) {
      if (dataSnap.value == null) {
        setState(() {
          _isLoading = true;
        });
      } else {
        newsList.clear();
        var keys = dataSnap.value.keys;
        var value = dataSnap.value;
        for (var key in keys) {
          var data = News(
            newsDate: DateTime.fromMillisecondsSinceEpoch(
                int.parse('${value[key]['date']}000')),
            newsContent: value[key]['desc'],
            newsTitleEN: value[key]['heading_en'],
            newsTitleMM: value[key]['heading_mm'],
            newsImg: value[key]['img'],
          );
          newsList.add(data);
          newsList.sort((a, b) => a.newsDate.compareTo(b.newsDate));
          newsList = newsList.reversed.toList();
        }
        setState(() {
          _isLoading = true;
        });
      }
    });
  }

  @override
  void initState() {
    widget.authFunction.getUser().then((user) {
      if (user == null) {
        setState(() {
          loggedIn = false;
        });
      } else if (user == "Not Verified User") {
        setState(() {
          loggedIn = false;
        });
      } else {
        setState(() {
          widget.authFunction.getEmail().then((email) {
            account = email;
          });
          loggedIn = true;
        });
      }
    });
    DBHelper dh = DBHelper();
    dh.initDb();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    logoAnimation = Tween(begin: 0.5, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    menuAnimation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {},
      onLaunch: (Map<String, dynamic> message) {},
      onResume: (Map<String, dynamic> message) {},
    );
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
    if (setLan == 'mm') {
      setState(() {
        _languageChg("Myanmar");
      });
    } else {
      setState(() {
        _languageChg("English");
      });
    }
    _fetchReminder();
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
          _getNews();
        });
      } else {
        setState(() {
          _connection = false;
          _conStatus = "No Internet Connection!";
        });
      }
    });
  }

  _fetchReminder() {
    Future<List<Reminder>> remind = reminderData();
    remind.then((value) {
      for (var i = 0; i < value.length; i++) {
        if (value[i].remindType == 'Reminder') {
          var reminder = Reminder(
            remindID: value[i].remindID,
            timeStamp: scheduleDate
                .parse(value[i].remindDate + " " + value[i].remindTime),
            remindDate: value[i].remindDate,
            remindTime: value[i].remindTime,
            remindType: value[i].remindType,
            remindAction: value[i].remindAction,
            remindNote: value[i].remindNote,
          );
          reminderList.add(reminder);
        } else {
          var appointment = Reminder(
            remindID: value[i].remindID,
            timeStamp: scheduleDate
                .parse(value[i].remindDate + " " + value[i].remindTime),
            remindDate: value[i].remindDate,
            remindTime: value[i].remindTime,
            remindType: value[i].remindType,
            remindAction: value[i].remindAction,
            remindNote: value[i].remindNote,
          );
          appointList.add(appointment);
        }
      }
      appointList.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      reminderList.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      for (var item in reminderList) {
        if (item.timeStamp.compareTo(DateTime.now()) >= 0) {
          setState(() {
            reminderShowDate = item.remindDate;
            reminderTime = item.remindTime;
            reminderTitle = item.remindAction;
          });
          break;
        }
      }
      for (var item in appointList) {
        if (item.timeStamp.compareTo(DateTime.now()) >= 0) {
          setState(() {
            appointShowDate = item.remindDate;
            appointTime = item.remindTime;
            appointTitle = item.remindAction;
          });
          break;
        }
      }
    });
  }

  _languageChg(String lang) {
    if (lang == "Myanmar") {
      setState(() {
        newsData = 'သတင်းများမရှိပါ';
        reminderTitle = 'သတိပေးချက်များမရှိပါ';
        appointTitle = 'ရက်ချိန်းများမရှိပါ';
        menuName = [
          'ဆေးမှတ်တမ်းစာအုပ်များ',
          'ဆရာဝန်များ',
          'ဆေးရုံများ',
          'ဆေးဝါးများ',
          'အသိပညာ',
          'အမေးအဖြေ'
        ];
        _viewAll = 'အားလုံးကြည့်ရန်';
        menuNews = "သတင်းများ";
        language = "mm";
        dynSize = 14.0;
        _isLoading = false;
        _checkCon();
      });
    } else {
      setState(() {
        newsData = 'No News';
        reminderTitle = 'No Reminder';
        appointTitle = 'No Appointment';
        menuName = [
          'Records Book',
          'Doctors',
          'Hospitals',
          'Medicines',
          'Knowledge',
          'Ask & Chat'
        ];
        _viewAll = 'View All';
        menuNews = "News";
        language = "en";
        dynSize = 16.0;
        _isLoading = false;
        _checkCon();
      });
    }
  }

  Future<bool> _exitApp() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Are you sure to exit the app?",
          style: TextStyle(color: Color(0xFF000000)),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text(
                "Yes",
                style: TextStyle(color: Color(0xFF333333)),
              ),
              onPressed: () => exit(0)),
          FlatButton(
              child: Text(
                "No",
                style: TextStyle(color: Color(0xFF333333)),
              ),
              onPressed: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }

  _menuRoute(String name) {
    if (name == "Records Book" || name == "ဆေးမှတ်တမ်းစာအုပ်များ") {
      Navigator.push(
          context,
          SlideRightAnimation(
              widget: ProfileScreen(
            authFunction: Authentic(),
            lan: language,
          )));
    } else if (name == "Doctors" || name == "ဆရာဝန်များ") {
      Navigator.push(
          context,
          SlideRightAnimation(
              widget: DoctorTypeList(
            language: language,
            appbarTitle: name,
          )));
    } else if (name == 'Medicines' || name == "ဆေးဝါးများ") {
      Navigator.push(
          context,
          SlideRightAnimation(
              widget: MedicineList(
            language: language,
            appbarTitle: name,
          )));
    } else if (name == 'Knowledge' || name == "အသိပညာ") {
      Navigator.push(
          context,
          SlideRightAnimation(
              widget: KnowledgeMainPage(
            appbarTitle: name,
            language: language,
          )));
    } else if (name == 'Ask & Chat' || name == "အမေးအဖြေ") {
      Navigator.push(
          context,
          SlideRightAnimation(
              widget: ChatRoom(
            appbarTitle: name,
            language: language,
            authFunction: Authentic(),
          )));
    } else if (name == 'Hospitals' || name == "ဆေးရုံများ") {
      Navigator.push(
          context,
          SlideRightAnimation(
              widget: Hospital(
            language,
          )));
    } else {
      _showSnackBar();
    }
  }

  _showSnackBar() {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Text(
        "Unavailable!",
        style: TextStyle(fontSize: 16.0),
      ),
      duration: Duration(seconds: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget _menuListWidgets(List<String> items) {
    List<Widget> menuList = List<Widget>();
    for (var i = 0; i < menuName.length; i++) {
      menuList.add(
        Card(
            color: Color(0xFF72bb53),
            child: FlatButton(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                onPressed: () {
                  _menuRoute(menuName[i]);
                },
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Image.asset(
                        menuIcon[i],
                        width: 28.0,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        menuName[i],
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: dynSize,
                            height: 0.75),
                      ),
                    )),
                  ],
                ))),
      );
    }
    return Column(
      children: menuList,
    );
  }

  _showUserInfo() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "User Info",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: Text("Logged In as $account"),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return WillPopScope(
          onWillPop: _exitApp,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xFF72bb53),
              centerTitle: true,
              leading: loggedIn == true
                  ? IconButton(
                      icon: Icon(
                        Icons.account_circle,
                        color: Color(0xFFFFFFFF),
                        size: 32.0,
                      ),
                      onPressed: _showUserInfo,
                    )
                  : null,
              title: Text(
                "OAAO Health Care".toUpperCase(),
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20.0),
              ),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: _languageChg,
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  itemBuilder: (BuildContext context) {
                    return MenuSetting.languages.map((String language) {
                      return PopupMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => Column(
                            children: <Widget>[
                              Transform(
                                transform: Matrix4.translationValues(
                                    animation.value * deviceWidth, 0.0, 0.0),
                                child: Container(
                                  margin: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color.fromRGBO(114, 187, 83, 0.25),
                                        blurRadius: 10.0)
                                  ]),
                                  child: Card(
                                    elevation: 3.6,
                                    child: FlatButton(
                                      highlightColor:
                                          Color.fromRGBO(255, 255, 255, 0.5),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            SlideRightAnimation(
                                                widget: ReminderList(
                                              language: language,
                                            )));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(
                                            leading: Image.asset(
                                              "assets/icons/noti_bell.png",
                                              width: 36.0,
                                            ),
                                            title: Text(
                                              reminderTitle.toUpperCase(),
                                              style: TextStyle(
                                                  color: Color(0xFF666666),
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              reminderShowDate,
                                              style: TextStyle(
                                                  color: Color(0xFF888888),
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            trailing: Text(
                                              reminderTime,
                                              style: TextStyle(
                                                  color: Color(0xFF666666),
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                          ListTile(
                                            leading: Image.asset(
                                              "assets/icons/noti_appointment.png",
                                              width: 36.0,
                                            ),
                                            title: Text(
                                              appointTitle.toUpperCase(),
                                              style: TextStyle(
                                                  color: Color(0xFF666666),
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              appointShowDate,
                                              style: TextStyle(
                                                  color: Color(0xFF888888),
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            trailing: Text(
                                              appointTime,
                                              style: TextStyle(
                                                  color: Color(0xFF666666),
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(16.0),
                                child: Row(
                                  children: <Widget>[
                                    Transform(
                                      transform: Matrix4.translationValues(
                                          0.0,
                                          logoAnimation.value * deviceWidth,
                                          0.0),
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/images/new_logo.png",
                                            width: (deviceWidth / 2) - 16,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(24.0),
                                            child: Text(
                                              'By',
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/logo.png",
                                            width: (deviceWidth / 2.5) - 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Transform(
                                      transform: Matrix4.translationValues(
                                          menuAnimation.value * deviceWidth,
                                          0.0,
                                          0.0),
                                      child: Container(
                                        width: (deviceWidth / 2) - 16,
                                        child: _menuListWidgets(menuName),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                                alignment: Alignment.centerLeft,
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0.0),
                                  title: Text(
                                    menuNews,
                                    style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          SlideFromBottomAnimation(
                                              widget: NewsList(
                                            language: language,
                                          )));
                                    },
                                    child: Text(
                                      _viewAll,
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize:
                                              language == 'mm' ? 14.0 : 16.0),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                child: Divider(
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                              ),
                              _connection == false
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Icon(
                                              Icons
                                                  .signal_cellular_connected_no_internet_4_bar,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 36.0,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16.0),
                                            child: Text(
                                              _conStatus,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _isLoading == false
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Theme.of(context).primaryColor),
                                          ),
                                        )
                                      : newsList.length > 0
                                          ? CarouselSlider(
                                              // distortion: false,
                                              items: newsList.map((i) {
                                                return Builder(
                                                  builder:
                                                      (BuildContext context) {
                                                    return Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              12.0,
                                                              8.0,
                                                              12.0,
                                                              8.0),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .title
                                                                  .color,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        114,
                                                                        187,
                                                                        83,
                                                                        0.5),
                                                                blurRadius:
                                                                    10.0)
                                                          ]),
                                                      child: FlatButton(
                                                        highlightColor:
                                                            Colors.transparent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              SlideFromBottomAnimation(
                                                                  widget:
                                                                      NewsPage(
                                                                news: i,
                                                                language:
                                                                    language,
                                                                appbarTitle:
                                                                    menuNews,
                                                              )));
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  alignment:
                                                                      AlignmentDirectional
                                                                          .centerStart,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        monthFormat
                                                                            .format(i.newsDate)
                                                                            .toString()
                                                                            .toUpperCase(),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).textTheme.title.color),
                                                                      ),
                                                                      Text(
                                                                          dateFormat
                                                                              .format(i
                                                                                  .newsDate)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(color: Theme.of(context).textTheme.title.color)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .event_note,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  size: 48.0,
                                                                )
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 12.0,
                                                                      bottom:
                                                                          0.0),
                                                              child: Text(
                                                                "${i.newsTitleEN}\n\n${i.newsTitleMM}",
                                                                maxLines: 4,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF333333),
                                                                    height: 1.5,
                                                                    fontSize:
                                                                        16.0),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                              height: 250.0,
                                              autoPlay: false,
                                              scrollDirection: Axis.horizontal,
                                              enableInfiniteScroll: false,
                                              viewportFraction: 0.9,
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(32.0),
                                              child: Text(
                                                newsData,
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                            )
                            ],
                          ),
                      childCount: 1),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
