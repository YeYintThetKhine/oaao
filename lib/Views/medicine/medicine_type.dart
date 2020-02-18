import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import '../../Models/medicine/med_type.dart';
import '../../Animations/slide_right_in.dart';
import '../../Views/medicine/medicine_list.dart';

class MedicineType extends StatefulWidget {
  final String language;
  MedicineType({this.language});
  @override
  _MedicineTypeState createState() => _MedicineTypeState(language: language);
}

class _MedicineTypeState extends State<MedicineType> {
  final String language;
  _MedicineTypeState({this.language});
  var _isLoading = true;
  var _connection;
  var _conStatus = "Unknown";
  Connectivity connectivity;
  var subscription;
  MedType medicineType;
  List<MedType> medTypeList = <MedType>[];

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
          _getMedType();
        });
      } else {
        setState(() {
          _connection = false;
          _conStatus = "No Internet Connection!";
        });
      }
    });
  }

  _getMedType() {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    dbRef
        .child('medicine_type')
        .child('en')
        .child('type')
        .once()
        .then((DataSnapshot dataSnap) {
      var types = dataSnap.value;
      var list = types.split(',');
      for (var i = 0; i < list.length; i++) {
        medicineType = new MedType(medType: list[i]);
        medTypeList.add(medicineType);
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Medicine Type",
                style:
                    TextStyle(color: Theme.of(context).textTheme.title.color),
              ),
              iconTheme: Theme.of(context).iconTheme,
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
                    : ListView.builder(
                        itemCount: medTypeList.length,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.0,
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: FlatButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    SlideRightAnimation(
                                      widget: MedicineList(),
                                    ));
                              },
                              child: ListTile(
                                title: Text(
                                  medTypeList[i].medType,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 18.0),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ));
      },
    );
  }
}
