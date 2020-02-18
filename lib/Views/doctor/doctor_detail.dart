import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/doctor/doctor.dart';
import '../../Models/doctor/doc_residing_clinic.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Views/doctor/residing_hospital.dart';

class DocDetail extends StatefulWidget {
  final Doctor doctor;
  final String language;
  DocDetail({this.doctor, this.language});
  @override
  _DocDetailState createState() =>
      _DocDetailState(doctor: doctor, language: language);
}

class _DocDetailState extends State<DocDetail> {
  final Doctor doctor;
  final String language;
  _DocDetailState({this.doctor, this.language});

  List<String> expList = [];
  List<String> eduList = [];
  ResidingClinic residingClinic;
  List<ResidingClinic> schedules = <ResidingClinic>[];
  var _residingClinic = true;
  var _isLoading = false;
  var name = 'Name';
  var specialist = 'Specialist';
  var edu = 'Education';
  var exp = 'Experiences';
  var residing = 'Residing Clinic';

  @override
  void initState() {
    super.initState();
    _setLanguage(language);
    _split();
    _fetchResidingClinic();
  }

  _setLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        name = 'နာမည်';
        specialist = 'အထူးကု';
        edu = 'ပညာရေး';
        exp = 'အတွေ့အကြုံ';
        residing = 'ထိုင်သောဆေးရုံများ';
      });
    }
  }

  _split() {
    expList = doctor.docExp.split(',');
    eduList = doctor.docEdu.split(',');
  }

  _fetchResidingClinic() {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    dbRef
        .child('residing_clinic')
        .child(doctor.docId)
        .once()
        .then((DataSnapshot residingSnap) {
      if (residingSnap.value == null) {
        setState(() {
          _isLoading = false;
          _residingClinic = false;
        });
      } else {
        var residingKeys = residingSnap.value.keys;
        var residingData = residingSnap.value;
        for (var key in residingKeys) {
          residingClinic = new ResidingClinic(
            hospitalID: residingData[key]['hosp_id'],
            hospitalTypeID: residingData[key]['hosp_type_id'],
            hospitalNameEN: residingData[key]['hosp_name_en'],
            hospitalNameMM: residingData[key]['hosp_name_mm'],
            schedule: residingData[key]['schedule'],
            type: residingData[key]['type'],
            phone: residingData[key]['phone'],
          );
          schedules.add(residingClinic);
        }
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _expWidgets(List<String> expriences) {
    List<Widget> expriencesList = new List<Widget>();
    for (String exp in expList) {
      expriencesList.add(Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Text(
          exp,
          style: TextStyle(
              fontSize: 16.0, color: Theme.of(context).textTheme.title.color),
        ),
      ));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: expriencesList);
  }

  Widget _eduWidgets(List<String> educations) {
    List<Widget> educationsList = new List<Widget>();
    for (String edu in eduList) {
      educationsList.add(Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Text(
          edu,
          style: TextStyle(
              fontSize: 16.0, color: Theme.of(context).textTheme.title.color),
        ),
      ));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: educationsList);
  }

  Widget _scheduleWidgets(List<String> timetable) {
    List<Widget> timetableList = new List<Widget>();
    for (String schedule in timetable) {
      timetableList.add(Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              schedule,
              style: TextStyle(fontSize: language == 'mm' ? 13.0 : 16.0),
            ),
          )
        ],
      ));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: timetableList);
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              iconTheme: Theme.of(context).iconTheme,
              pinned: true,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                background: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    doctor.docImg.length > 0
                        ? Image.network(
                            doctor.docImg,
                            fit: BoxFit.cover,
                            height: 250.0,
                          )
                        : Image.asset(
                            'assets/images/default_doc.jpg',
                            fit: BoxFit.cover,
                            height: 250.0,
                          ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment(0.0, -1.0),
                            end: Alignment(0.0, -0.08),
                            colors: <Color>[
                              Color(0x60000000),
                              Color(0x00000000)
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: new SliverChildBuilderDelegate(
                    (context, index) => Padding(
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 5.0),
                          child: new Column(
                            children: <Widget>[
                              new Padding(
                                padding:
                                    EdgeInsets.only(top: 10.0, bottom: 5.0),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${doctor.docNameEN}\n${doctor.docNameMM}',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                      ),
                                    ),
                                    Divider(
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color,
                                    ),
                                    ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          specialist,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${doctor.docTypeEN}\n${doctor.docTypeMM}',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .title
                                                .color),
                                      ),
                                    ),
                                    Divider(
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color),
                                    ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          edu,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(
                                            left: 0.0, top: 5.0, right: 10.0),
                                        child: _eduWidgets(eduList),
                                      ),
                                    ),
                                    Divider(
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color),
                                    ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          exp,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .color),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(
                                            left: 0.0, top: 5.0, right: 10.0),
                                        child: _expWidgets(expList),
                                      ),
                                    ),
                                    Divider(
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 16.0,
                                              top: 12.0,
                                              bottom: 12.0),
                                          child: Text(
                                            residing,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .color,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                        _isLoading == true
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Theme.of(context)
                                                              .textTheme
                                                              .title
                                                              .color),
                                                ),
                                              )
                                            : _residingClinic == false
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 16.0,
                                                        top: 12.0,
                                                        bottom: 12.0),
                                                    child: Text(
                                                      language == 'mm'
                                                          ? 'မရှိပါ'
                                                          : 'No Residing Clinic',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : Container(
                                                    height: language == 'mm'
                                                        ? 500.0
                                                        : 500.0,
                                                    child: ListView.builder(
                                                      itemCount:
                                                          schedules.length,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, i) {
                                                        return Container(
                                                          width: orientation ==
                                                                  Orientation
                                                                      .landscape
                                                              ? device.width /
                                                                      2 -
                                                                  25.0
                                                              : device.width -
                                                                  50.0,
                                                          child: new Card(
                                                            elevation: 1.2,
                                                            child: new Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                ListTile(
                                                                    title:
                                                                        Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 8.0),
                                                                      child:
                                                                          Text(
                                                                        "${schedules[i].hospitalNameEN}\n${schedules[i].hospitalNameMM}",
                                                                        style: TextStyle(
                                                                            fontSize: language == 'mm'
                                                                                ? 15.0
                                                                                : 18.0),
                                                                      ),
                                                                    ),
                                                                    subtitle:
                                                                        Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 8.0),
                                                                      child: _scheduleWidgets(schedules[
                                                                              i]
                                                                          .schedule
                                                                          .split(
                                                                              ',')),
                                                                    )),
                                                                new ButtonTheme
                                                                    .bar(
                                                                  buttonColor: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  child:
                                                                      new ButtonBar(
                                                                    alignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      new RaisedButton(
                                                                        child:
                                                                            Text(
                                                                          "View Hospital",
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => ResidingHospital(
                                                                                hospID: schedules[i].hospitalID,
                                                                                hospTypeID: schedules[i].hospitalTypeID,
                                                                                lan: language,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                      new RaisedButton(
                                                                          child:
                                                                              Text(
                                                                            "Make Appointment",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            var appointPh =
                                                                                schedules[i].phone;
                                                                            if (appointPh == null ||
                                                                                appointPh == 'Nil') {
                                                                              final snackBar = SnackBar(
                                                                                content: Text('Unavailable!'),
                                                                              );
                                                                              Scaffold.of(context).showSnackBar(snackBar);
                                                                            } else {
                                                                              launch('tel:$appointPh');
                                                                            }
                                                                          }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                    childCount: 1))
          ]),
        );
      },
    );
  }
}
