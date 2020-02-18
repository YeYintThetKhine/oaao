import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/doctor/doctor.dart';
import '../../Views/doctor/doctor_detail.dart';
import 'package:material_search/material_search.dart';
import '../../Animations/slide_right_in.dart';

class DocList extends StatefulWidget {
  final String docType;
  final String typeEN;
  final String typeMM;
  final String language;
  DocList({this.docType, this.language, this.typeEN, this.typeMM});
  @override
  _DocListState createState() => _DocListState(
      docType: docType, language: language, typeEN: typeEN, typeMM: typeMM);
}

class _DocListState extends State<DocList> {
  final String docType;
  String typeEN;
  String typeMM;
  final String language;
  _DocListState({this.docType, this.language, this.typeEN, this.typeMM});
  List<String> docNames = [];

  Doctor doctor = new Doctor();
  List<Doctor> docList = <Doctor>[];
  var _isLoading = true;
  var _noData = false;
  var apptitle = 'Doctor List';
  var docData = 'No Doctor';
  String searchName;

  @override
  void initState() {
    super.initState();
    _getDocList();
    _setLanguage(language);
  }

  _setLanguage(var lan) {
    if (lan == 'mm') {
      apptitle = 'ဆရာဝန်များ';
      docData = 'မရှိပါ';
    }
  }

  _getDocList() {
    DatabaseReference dbRef = FirebaseDatabase.instance.reference();
    dbRef.child('doctors').child(docType).once().then((DataSnapshot dataSnap) {
      if (dataSnap.value != null) {
        var ids = dataSnap.value.keys;
        var docs = dataSnap.value;
        for (var id in ids) {
          doctor = new Doctor(
              docId: id,
              docImg: docs[id]['img'],
              docNameEN: docs[id]['name_en'],
              docNameMM: docs[id]['name_mm'],
              docTypeEN: typeEN,
              docTypeMM: typeMM,
              docEdu: docs[id]['education'],
              docExp: docs[id]['experiences']);
          docList.add(doctor);
          docNames.add('${docs[id]['name_en']}\n${docs[id]['name_mm']}');
        }
      } else {
        _noData = true;
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  _buildMaterialSearchPage(BuildContext context) {
    return new MaterialPageRoute<String>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        builder: (BuildContext context) {
          return new Material(
            child: new GestureDetector(
              onTap: () {
                // call this method here to hide soft keyboard
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new MaterialSearch<String>(
                iconColor: Theme.of(context).iconTheme.color,
                barBackgroundColor: Theme.of(context).primaryColor,
                placeholder: 'Search',
                results: docNames
                    .map((String v) => new MaterialSearchResult<String>(
                          value: v,
                          text: docNames.length > 0 ? "$v" : "No Medicine",
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

  routeToDetailPage(String docName) {
    for (Doctor doc in docList) {
      if (docName.substring(0, docName.indexOf('\n')) == doc.docNameEN) {
        Navigator.push(
            context,
            SlideRightAnimation(
                widget: DocDetail(
              language: language,
              doctor: doc,
            )));
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
    var device = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientaion) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: Theme.of(context).iconTheme,
            title: Text(
              apptitle,
              style: TextStyle(color: Theme.of(context).textTheme.title.color),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _showMaterialSearch(context);
                },
              )
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  ),
                )
              : _noData == true
                  ? Center(
                      child: Text(
                        docData,
                        style: TextStyle(fontSize: 24.0),
                      ),
                    )
                  : ListView.builder(
                      itemCount: docList.length,
                      itemBuilder: (context, i) {
                        return Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Color.fromRGBO(114, 187, 83, 0.5),
                            )
                          ]),
                          margin: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
                          child: FlatButton(
                            padding: EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DocDetail(
                                            doctor: docList[i],
                                            language: language,
                                          )));
                            },
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: <Widget>[
                                Container(
                                  height: orientaion == Orientation.landscape
                                      ? (device.height -
                                              12 -
                                              kToolbarHeight -
                                              12.0) /
                                          2
                                      : (device.height -
                                              12 -
                                              kToolbarHeight -
                                              12.0) /
                                          4,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      top: 70, left: 20, right: 20, bottom: 20),
                                  margin: EdgeInsets.only(top: 75.0),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0))),
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10.0),
                                        child: Text(
                                          '${docList[i].docNameEN}\n' +
                                              '${docList[i].docNameMM}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: language == 'en'
                                                  ? 20.0
                                                  : 16.0,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                      Container(
                                        child: new Row(
                                          children: <Widget>[
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Image.asset(
                                                'assets/icons/doc_edu.png',
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 28.0,
                                              ),
                                            ),
                                            new Expanded(
                                              child: new Container(
                                                child: Text(
                                                  docList[i].docEdu,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                      fontSize: language == 'en'
                                                          ? 15.0
                                                          : 13.0,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 25.0),
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: docList[i].docImg.length > 0
                                          ? NetworkImage(
                                              docList[i].docImg,
                                            )
                                          : AssetImage(
                                              'assets/images/default_doc.jpg'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
