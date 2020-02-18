import 'dart:async';

import 'package:flutter/material.dart';
import '../../Models/records_book/record_book.dart';
import '../../Views/records_book/imageview.dart';
import '../../Database/database.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../Views/records_book/recordedit.dart';

class DetailScreen extends StatefulWidget {
  final Records rd;
  final lan;
  DetailScreen({@required this.rd, @required this.lan});
  DetailScreenState createState() => DetailScreenState(record: rd, lan: lan);
}

class DetailScreenState extends State<DetailScreen> {
  DBHelper dbh = DBHelper();
  Records record;
  final lan;
  DetailScreenState({@required this.record, @required this.lan});

  Future<List<ImageData>> fetchimagesFromDatabase() async {
    var dbHelper = DBHelper();
    Future<List<ImageData>> records =
        dbHelper.fetchImageDataList(userid: record.userid, recid: record.recid);
    return records;
  }

  Future<Records> fetchrecordsFromDatabase() async {
    var dbHelper = DBHelper();
    Future<Records> records =
        dbHelper.fetchaRecord(record.userid, record.recid);
    return records;
  }

  Widget _recordDetail() {
    return FutureBuilder<Records>(
        future: fetchrecordsFromDatabase(),
        builder: (context, snapshot) => (snapshot.hasData)
            ? Container(
                padding: EdgeInsets.only(left: 8.0, top: 8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                      child: ListTile(
                        leading: SizedBox(
                          width: 60.0,
                          child: Text(
                              lan == 'en' ? 'Created Date' : 'ဖန်တီးသောနေ့',
                              style: TextStyle(
                                  color: Color(0xFF5b9542),
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(snapshot.data.date),
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                      child: ListTile(
                        leading: SizedBox(
                          width: 60.0,
                          child: Text(lan == 'en' ? 'Doctor' : 'ဆရာဝန်',
                              style: TextStyle(
                                  color: Color(0xFF5b9542),
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(snapshot.data.doctor),
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                      child: ListTile(
                        leading: SizedBox(
                          width: 60.0,
                          child: Text(lan == 'en' ? 'Hospital' : 'ဆေးရုံ',
                              style: TextStyle(
                                  color: Color(0xFF5b9542),
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(snapshot.data.hospital),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: ListTile(
                          leading: SizedBox(
                            width: 60.0,
                            child: Text(lan == 'en' ? 'Problem' : 'မှတ်တမ်း',
                                style: TextStyle(
                                    color: Color(0xFF5b9542),
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(snapshot.data.problem),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Text('NTH'));
  }

  Widget _recordImages() {
    return FutureBuilder<List<ImageData>>(
        future: fetchimagesFromDatabase(),
        builder: (context, snapshot) => (snapshot.hasData &&
                snapshot.data.length != 0)
            ? Container(
                color: Colors.lightGreen[300],
                child: Swiper(
                  itemHeight: 300.0,
                  itemWidth: 300.0,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) =>
                      Image.memory(snapshot.data[index].imgData),
                  loop: false,
                  pagination: SwiperPagination(builder: SwiperPagination.dots),
                  control: SwiperControl(),
                  viewportFraction: 0.86,
                  scale: 0.5,
                  onTap: (na) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShowImages(
                              imgdata: snapshot.data[na].imgData,
                            )));
                  },
                ),
              )
            : Center(
                child: Container(
                  color: Colors.grey[300],
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset('assets/images/image.jpg'),
                ),
              ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        label: Text(lan == 'en' ? 'Delete' : 'ဖျက်မည်'),
        icon: Icon(Icons.delete),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    content: Text(
                        lan == "en"
                            ? 'Delete this record?'
                            : 'ဤမှတ်တမ်းကိုဖျက်ရန်လိုပါသလား?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          lan == 'en' ? 'Cancel' : "ရုပ်သိမ်း",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text(lan == 'en' ? 'Delete' : "ဖျက်မည်",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            )),
                        onPressed: () {
                          dbh.deleteRecord(record.recid);
                          print('Record deleted');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ));
          //
        },
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(lan == 'en' ? 'Record Details' : 'မှတ်တမ်းအသေးစိတ်',
            style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RecordEdit(
                        record: record,
                        lan: lan,
                      )));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                child: _recordDetail(),
              ),
              Container(
                height: 300,
                child: _recordImages(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
