import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../Database/database.dart';
import '../../Models/records_book/record_book.dart';
import '../records_book/meddetail.dart';

class RecordSearch extends StatefulWidget {
  final uid;
  final lan;
  RecordSearch({@required this.uid, @required this.lan});
  _RecordSearchState createState() => _RecordSearchState(uid: uid, lan: lan);
}

class _RecordSearchState extends State<RecordSearch> {
  var _textStyle =
      TextStyle(color: Color(0xFF72BB53), fontWeight: FontWeight.bold);
  List<Records> filteredProblems = new List();
  String _searchText = "";
  final uid;
  final lan;
  _RecordSearchState({@required this.uid, @required this.lan}) {
    keyword.addListener(() {
      if (keyword.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredProblems = items;
        });
      } else {
        setState(() {
          _searchText = keyword.text;
        });
      }
    });
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List<Records> tempList = List();
      filteredProblems = items;
      for (int i = 0; i < filteredProblems.length; i++) {
        if (filteredProblems[i]
            .problem
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredProblems[i]);
        }
      }
      filteredProblems = tempList;
    } else {
      filteredProblems = items;
    }
    return ListView.builder(
      itemCount: items == null ? 0 : filteredProblems.length,
      itemBuilder: (context, i) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 2.0,
          margin:
              EdgeInsets.only(left: 12.0, right: 12.0, top: 6.0, bottom: 6.0),
          child: InkWell(
              child: Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Color(0xFF72BB53),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80,
                            padding: EdgeInsets.only(
                              left: 8.0,
                            ),
                            child: Text(
                              lan == 'en' ? 'Doctor' : 'ဆရာဝန်',
                              style: _textStyle,
                            ),
                          ),
                          Expanded(
                            child: Text(filteredProblems[i].doctor),
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 80,
                              padding: EdgeInsets.only(
                                left: 8.0,
                              ),
                              child: Text(
                                lan == 'en' ? 'Hospital' : 'ဆေးရုံ',
                                style: _textStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(filteredProblems[i].hospital),
                            )
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 80,
                              padding: EdgeInsets.only(
                                left: 8.0,
                              ),
                              child: Text(
                                lan == 'en' ? 'Problem' : 'မှတ်တမ်း',
                                style: _textStyle,
                              ),
                            ),
                            Expanded(
                              child: Text(filteredProblems[i].problem),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) =>
                        DetailScreen(rd: filteredProblems[i], lan: lan)));
              }),
        );
      },
    );
  }

  TextEditingController keyword = TextEditingController();
  var items = List<Records>();
  DBHelper db = DBHelper();

  Future<void> fetchRecordData() async {
    var result = await db.fetchRecordsList(userid: uid, order: 'ASC');
    setState(() {
      items = result;
    });
  }

  void initState() {
    super.initState();
    fetchRecordData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          // title: Text('Search By Problem',style:TextStyle(color: Colors.white))
        ),
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
                child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      left: 12.0, right: 12.0, top: 10.0, bottom: 8.0),
                  child: TextField(
                    controller: keyword,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26.0)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26.0),
                            borderSide: BorderSide(color: Color(0xFF72BB53))),
                        labelText: lan == 'en'
                            ? 'Search By Problem'
                            : 'မှတ်တမ်းဖြင့်ရှာဖွေပါ'),
                  ),
                ),
                Expanded(child: _buildList()),
              ],
            ))));
  }
}
