import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/hospital/clinic.dart';
import '../../Models/hospital/hospital_type.dart';
import 'hospitallist_n.dart';
import '../../Animations/scale.dart';
import 'package:connectivity/connectivity.dart';

class Hospital extends StatefulWidget {
  final language;
  Hospital(this.language);
  _HospitalState createState() => _HospitalState(language);
}

class _HospitalState extends State<Hospital>
    with SingleTickerProviderStateMixin {
  String type;
  final language;
  var lan;
  var title;
  bool loading;
  var typearr = [];
  Set<HType> category = Set();
  HType htype;
  Set<HType> cat = Set();
  _HospitalState(this.language);

  Animation animation;
  AnimationController animationController;
  var _connection;
  var _conStatus = "Unknown";
  Connectivity connectivity;
  var subscription;
  HospitalType hospType;
  List<HospitalType> hospList = [];
  List countList = [];

  _loadData() {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref.child('hospital_type').once().then((DataSnapshot snap) {
      if (snap.value == null) {
      } else {
        var ids = snap.value.keys;
        var hospTypeList = snap.value;
        for (var id in ids) {
          hospType = new HospitalType(
            id: id,
            typeEN: hospTypeList[id]['type_en'],
            typeMM: hospTypeList[id]['type_mm'],
          );
          hospList.add(hospType);
          typearr.add(id);
        }
        _loadCount();
      }
    });
  }

  _checkConnection() {
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          _connection = true;
          _loadData();
        });
      } else {
        setState(() {
          _connection = false;
          _conStatus = "No Internet Connection!";
        });
      }
    });
  }

  _loadCount() {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    for (var type in typearr) {
      dbRef.child('hospitals').child(type).once().then((DataSnapshot dataSnap) {
        if (dataSnap.value == null) {
          setState(() {
            countList.add(0.toString());
          });
        } else {
          var count = dataSnap.value.keys;
          setState(() {
            countList.add(count.length.toString());
          });
        }
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();

    loading = true;
    if (language == "mm") {
      lan = "mm";
      title = "ဆေးရုံအမျိုးအစား";
    } else {
      lan = "en";
      title = "Hospital Type";
    }
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Color(0xFF72BB53),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.title.color),
        ),
      ),
      body: Container(
        child: _connection == false
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Icon(
                        Icons.signal_cellular_connected_no_internet_4_bar,
                        color: Theme.of(context).primaryColor,
                        size: 36.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _conStatus,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                child: loading || countList.length != typearr.length
                    ? Center(
                        child: Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF72BB53)),
                          ),
                        ),
                      )
                    : AnimatedBuilder(
                        animation: animationController,
                        builder: (BuildContext context, Widget widget) =>
                            ListView.builder(
                          itemCount: typearr.length,
                          itemBuilder: (context, index) => Transform(
                            transform: Matrix4.translationValues(
                                animation.value *
                                    MediaQuery.of(context).size.width,
                                0.0,
                                0.0),
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.0, right: 4.0),
                              child: Card(
                                elevation: 4.0,
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8.0,
                                      left: 12.0,
                                      right: 12.0),
                                  title: Text(
                                      "${hospList.elementAt(index).typeEN}\n${hospList.elementAt(index).typeMM}",
                                      style:
                                          TextStyle(color: Color(0xFF72BB53))),
                                  trailing: CircleAvatar(
                                      backgroundColor: Color(0xFF72BB53),
                                      maxRadius: 13.6,
                                      foregroundColor: Colors.white,
                                      child: Text(countList[index])),
                                  onTap: () {
                                    if (countList[index] != 0)
                                      Navigator.push(
                                        context,
                                        ScaleRoute(
                                          widget: HospitalList(
                                            hostype:
                                                hospList[index].id.toString(),
                                            language: language,
                                          ),
                                        ),
                                      );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
      ),
    );
  }
}
