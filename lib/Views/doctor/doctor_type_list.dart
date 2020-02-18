import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/doctor/doc_type.dart';
import '../../Views/doctor/doctor_list.dart';
import 'package:connectivity/connectivity.dart';

class DoctorTypeList extends StatefulWidget {
  final String language;
  final String appbarTitle;
  DoctorTypeList({this.language, this.appbarTitle});
  @override
  _DoctorTypeListState createState() =>
      _DoctorTypeListState(language: language, appbarTitle: appbarTitle);
}

class _DoctorTypeListState extends State<DoctorTypeList>
    with SingleTickerProviderStateMixin {
  final String language;
  String appbarTitle;
  _DoctorTypeListState({this.language, this.appbarTitle});
  Animation animation;
  AnimationController animationController;

  DocType docType;
  List<DocType> docTypeList = <DocType>[];
  List<String> countList = [];
  var _isLoading = true;
  var _isNull = false;
  var _connection;
  var _conStatus = "Unknown";
  Connectivity connectivity;
  var subscription;
  var noData = 'Not Available';

  @override
  void initState() {
    super.initState();
    _setLanguage(language);
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _checkCon();
  }

  _setLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        noData = 'မရှိပါ';
        appbarTitle = 'အထူးကုအမျိူးအစားများ';
      });
    } else {
      appbarTitle = 'Specialist List';
    }
  }

  _checkCon() {
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          _connection = true;
          _getDocType();
        });
      } else {
        setState(() {
          _connection = false;
          _conStatus = "No Internet Connection!";
        });
      }
    });
  }

  _animation() {
    animation = Tween(begin: -0.7, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    animationController.forward();
  }

  _getDocType() {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    dbRef.child('doctor_type').once().then((DataSnapshot dataSnap) {
      if (dataSnap.value == null) {
        setState(() {
          _isLoading = false;
          _isNull = true;
        });
      } else {
        var types = dataSnap.value.keys;
        var typeIcons = dataSnap.value;
        for (var type in types) {
          docType = new DocType(
            id: type,
            typeIcon: typeIcons[type]['img'],
            typeEN: typeIcons[type]['type_en'],
            typeMM: typeIcons[type]['type_mm'],
          );
          docTypeList.add(docType);
        }
        _getDocCount(types);
      }
    });
  }

  _getDocCount(var types) {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    for (var type in types) {
      dbRef.child('doctors').child(type).once().then((DataSnapshot dataSnap) {
        if (dataSnap.value == null) {
          countList.add(0.toString());
        } else {
          var count = dataSnap.value.keys;
          countList.add(count.length.toString());
        }
        setState(() {
          _isLoading = false;
          _animation();
        });
      });
    }
  }

  _docListRoute(String type, String typeNameEN, String typeNameMM) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DocList(
                  docType: type,
                  typeEN: typeNameEN,
                  typeMM: typeNameMM,
                  language: language,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        var device = MediaQuery.of(context).size;
        return OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  iconTheme: Theme.of(context).iconTheme,
                  title: Text(
                    appbarTitle,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color),
                  ),
                ),
                body: _connection == false
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Icon(
                              Icons.signal_cellular_connected_no_internet_4_bar,
                              color: Theme.of(context).primaryColor,
                              size: 64.0,
                            ),
                          ),
                          Text(
                            _conStatus,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20.0),
                          ),
                        ],
                      ))
                    : _isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          )
                        : _isNull == true
                            ? Container(
                                child: Center(
                                  child: Text(
                                    noData,
                                    style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 20.0),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: countList.length,
                                itemBuilder: (context, i) {
                                  return Transform(
                                    transform: Matrix4.translationValues(
                                        animation.value * device.width,
                                        0.0,
                                        0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                              width: 1.0,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 5.0,
                                              color: Color.fromRGBO(
                                                  114, 187, 83, 0.5),
                                            )
                                          ]),
                                      margin: EdgeInsets.fromLTRB(
                                          12.0, 5.0, 12.0, 5.0),
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        padding: EdgeInsets.all(0.0),
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color,
                                        onPressed: () {
                                          _docListRoute(
                                              docTypeList[i].id,
                                              docTypeList[i].typeEN,
                                              docTypeList[i].typeMM);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 8.0),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              radius: 28.0,
                                              child: Image.network(
                                                docTypeList[i].typeIcon,
                                                width: 45.0,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .color,
                                              ),
                                            ),
                                            title: Text(
                                              '${docTypeList[i].typeEN} \n${docTypeList[i].typeMM}',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            trailing: Chip(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              label: Text(
                                                countList[i],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .color,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ));
          },
        );
      },
    );
  }
}
