import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/medicine/medicine.dart';
import 'package:material_search/material_search.dart';
import 'medicine_detail.dart';
import '../../Animations/slide_right_in.dart';

class MedicineList extends StatefulWidget {
  final String language;
  final String appbarTitle;
  MedicineList({this.language, this.appbarTitle});
  @override
  _MedicineListState createState() =>
      _MedicineListState(language: language, appbarTitle: appbarTitle);
}

class _MedicineListState extends State<MedicineList> {
  final String language;
  final String appbarTitle;
  _MedicineListState({this.language, this.appbarTitle});
  var _isLoading = false;
  var _connection = true;
  var _conStatus = 'Unknown';
  Connectivity connectivity;
  var subscription;
  var _isNull = false;
  Medicine med;
  List<Medicine> medList = <Medicine>[];
  List<String> medNames = <String>[];
  String searchName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          _getMedicine();
        });
      } else {
        setState(() {
          _isLoading = true;
          _connection = false;
          _conStatus = "No Internet Connection!";
        });
      }
    });
  }

  _getMedicine() {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child('medicines').once().then((DataSnapshot dataSnap) {
      if (dataSnap.value == null) {
        setState(() {
          _isNull = true;
        });
      } else {
        var keys = dataSnap.value.keys;
        var data = dataSnap.value;
        for (var key in keys) {
          Medicine med = new Medicine(
            medId: key,
            medImg: data[key]['img'],
            medNameEN: data[key]['name_en'],
            medNameMM: data[key]['name_mm'],
            medManuf: data[key]['manufacture'],
            medDesc: data[key]['description'],
          );
          medList.add(med);
          medNames.add("${med.medNameEN}\n${med.medNameMM}");
        }
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  _buildMaterialSearchPage(BuildContext context) {
    return new MaterialPageRoute<String>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        builder: (BuildContext context) {
          return Material(
            child: new GestureDetector(
              onTap: () {
                // call this method here to hide soft keyboard
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new MaterialSearch<String>(
                iconColor: Theme.of(context).iconTheme.color,
                barBackgroundColor: Theme.of(context).primaryColor,
                placeholder: 'Search',
                results: medNames
                    .map((String v) => new MaterialSearchResult<String>(
                          value: v,
                          text: "$v",
                        ))
                    .toList(),
                filter: (dynamic value, String criteria) {
                  return value.toLowerCase().trim().contains(
                      new RegExp(r'' + criteria.toLowerCase().trim() + ''));
                },
                onSelect: (dynamic value) => routeToDetailPage(value),
                onSubmit: (String value) => routeToDetailPage(value),
              ),
            ),
          );
        });
  }

  _showSnackbar() {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Text(
        "No Medicine to Search",
        style: TextStyle(fontSize: 16.0),
      ),
      duration: Duration(seconds: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  routeToDetailPage(String medname) {
    for (Medicine medicine in medList) {
      if (medname.substring(0, medname.indexOf('\n')) == medicine.medNameEN) {
        Navigator.push(
          context,
          SlideRightAnimation(
            widget: MedicineDetail(
              medicine: medicine,
            ),
          ),
        );
      }
    }
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
        .push(_buildMaterialSearchPage(context))
        .then((dynamic value) {
      setState(() => searchName = value as String);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                appbarTitle,
                style:
                    TextStyle(color: Theme.of(context).textTheme.title.color),
              ),
              iconTheme: Theme.of(context).iconTheme,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _isNull == true
                        ? _showSnackbar()
                        : _showMaterialSearch(context);
                  },
                )
              ],
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
                    : Container());
      },
    );
  }
}
