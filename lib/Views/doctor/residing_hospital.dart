import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/hospital/clinic.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:firebase_database/firebase_database.dart';

class ResidingHospital extends StatefulWidget {
  final String hospID;
  final String hospTypeID;
  final String lan;
  ResidingHospital(
      {@required this.hospID, this.hospTypeID, @required this.lan});
  _ResidingHospitalState createState() => _ResidingHospitalState(
      hospID: hospID, language: lan, hospTypeID: hospTypeID);
}

class _ResidingHospitalState extends State<ResidingHospital> {
  var facilitylist = [];
  var fb = "Facebook";
  var mail = "Email";
  var location = "Location";
  var ph = "Phone";
  var fax = "Fax";
  var site = "Webiste";
  String lan;
  var _notFound = false;
  var _isLoading = true;
  String flist;
  Set<FacilityService> facility = new Set<FacilityService>();
  var coord = [];
  var _services = true;
  Clinic hosp;
  final String hospID;
  final String language;
  final String hospTypeID;
  _ResidingHospitalState(
      {@required this.hospID, @required this.language, this.hospTypeID});

  _loadData() {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    ref
        .child('hospitals')
        .child(hospTypeID)
        .child(hospID)
        .once()
        .then((DataSnapshot snap) {
      var data = snap.value;
      if (snap.value == null) {
        setState(() {
          _notFound = true;
          _isLoading = false;
        });
      } else {
        hosp = Clinic(
          clinicimg: data['img'],
          nameMM: data['name_mm'],
          nameEN: data['name_en'],
          location: data['location'],
          telephone: data['phone'],
          fax: data['fax'],
          email: data['email'],
          website: data['website'],
          facebook: data['facebook'],
          map: data['map'],
        );
        ref.child('facility').child(hospID).once().then((DataSnapshot snap) {
          var data = snap.value;
          if (snap.value != null) {
            FacilityService c = new FacilityService(
              servicename: data['services'],
            );
            setState(() {
              facility.add(c);
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _services = false;
            });
          }
        });
        setState(() {
          String phnums = hosp.telephone;
          phones = phnums.split(',');

          String mapcoor = hosp.map;
          coord = mapcoor.split(',');
        });
      }
    });
  }

//to automatically perform _loadData function to decode JSON
  @override
  void initState() {
    super.initState();
    if (language == 'mm') {
      setState(() {
        fb = "Facebook";
        mail = "Email";
        location = "တည်နေရာ";
        ph = "ဖုန်းနံပါတ်";
        fax = "Fax နံပါတ်";
        site = "Webiste";
      });
    } else {
      setState(() {
        fb = "Facebook";
        mail = "Email";
        location = "Location";
        ph = "Phone";
        fax = "Fax";
        site = "Webiste";
      });
    }
    _loadData();
  }

  var phones = [];
  @override
  Widget build(BuildContext context) {
    if (facility.isEmpty == false) {
      for (FacilityService _service in facility) {
        setState(() {
          flist = _service.servicename;
          facilitylist = flist.split(',');
        });
      }
    }

    return Hero(
      tag: 'Hospital',
      child: Scaffold(
          body: _isLoading == true
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor),
                    ),
                  ),
                )
              : _notFound == false
                  ? CustomScrollView(
                      slivers: <Widget>[
                        _buildSilverAppBar(),
                        _detailinfo(),
                      ],
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              "Not Available",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                          FlatButton(
                            child: Text("Back",
                                style: TextStyle(color: Color(0xFFFFFFFF))),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    )),
    );
  }

//Showing map in a Dialog Box
  Widget showMap() {
    return new FlutterMap(
      options: MapOptions(
          center: LatLng(double.parse(coord[0]), double.parse(coord[1])),
          maxZoom: 18.0,
          minZoom: 14.0,
          zoom: 15.0),
      layers: [
        TileLayerOptions(
          urlTemplate: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(markers: [
          new Marker(
              point: LatLng(double.parse(coord[0]), double.parse(coord[1])),
              width: 70.0,
              height: 70.0,
              builder: (context) => Icon(
                    Icons.place,
                    color: Colors.red,
                  ))
        ])
      ],
    );
  }

//A widget to populate the container to show facilities and services
  Widget _text() {
    List<Widget> list = new List<Widget>();
    list.add(Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Text(
        language == 'mm' ? 'ဝန်ဆောင်မှုများ' : 'Facility & Services',
        style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF72BB53)),
      ),
    ));

    if (_services == false) {
      list.add(Container(
        padding: EdgeInsets.only(left: 60.0, bottom: 16.0),
        child: new Text("Not Available"),
        alignment: Alignment.centerLeft,
      ));
    } else {
      //Seperating each and every facility & service with a divider to make them appear organized in the box
      for (String name in facilitylist) {
        list.add(Container(
          padding: EdgeInsets.only(left: 60.0),
          child: new Text(name),
          alignment: Alignment.centerLeft,
        ));
        list.add(Divider(
          color: Colors.white,
        ));
      }
    }
    return new Column(
      children: list,
    );
  }

  Widget showPhNums() {
    var phlist = List<Widget>();
    for (var ph in phones) {
      phlist.add(Container(
        alignment: Alignment.center,
        child: ListTile(
          title: Text(ph),
          trailing: Icon(Icons.call, color: Color(0xFF72BB53)),
          onTap: () {
            var phnumss = ph.toString();
            var phnos = phnumss.replaceAll('-', '');
            launch('tel:$phnos');
          },
        ),
      ));
    }
    return Column(
      children: phlist,
    );
  }

//A box to show facilites and services
  Widget _facility() {
    return Container(
      child: Container(child: _text()),
    );
  }

  void _showPhDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new Container(
            child: AlertDialog(
              title: Text(
                'Choose a number',
                style: TextStyle(color: Color(0xFF666666)),
              ),
              content: SingleChildScrollView(
                  child: ListBody(
                children: <Widget>[showPhNums()],
              )),
              actions: <Widget>[
                FlatButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  final _appbarheight = 225.0; //Maximum height for collapsing app bar

  //Stylish App bar for attraction
  Widget _buildSilverAppBar() {
    return SliverAppBar(
      pinned: true,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Color(0xFF72BB53),
      expandedHeight: _appbarheight,
      flexibleSpace: FlexibleSpaceBar(
        background: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            hosp.clinicimg != null
                ? Image.asset('assets/images/default_hospital.jpg')
                : Image.network(
                    hosp.clinicimg,
                    fit: BoxFit.cover,
                    height: _appbarheight,
                  ),
            const DecoratedBox(
              decoration: const BoxDecoration(
                gradient: const LinearGradient(
                    begin: const Alignment(0.0, -1.0),
                    end: const Alignment(0.0, -0.08),
                    colors: const <Color>[
                      const Color(0x60000000),
                      const Color(0x00000000)
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

//Information of hospital
  Widget _detailinfo() {
    return new SliverList(
        delegate: new SliverChildBuilderDelegate(
            (context, position) => new Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "${hosp.nameEN}\n${hosp.nameMM}",
                          style: TextStyle(
                              fontSize: 20.0, color: Color(0xFF72BB53)),
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.place,
                        color: Color(0xFF72BB53),
                      ),
                      title: Text(hosp.location),
                      subtitle: Text(location,
                          style: TextStyle(color: Colors.green[300])),
                      onTap: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return new Container(
                                child: AlertDialog(
                                  title: Text(
                                    '${hosp.nameEN}\n${hosp.nameMM}',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFF666666)),
                                  ),
                                  content: SingleChildScrollView(
                                      child: ListBody(
                                    children: <Widget>[
                                      new Container(
                                        child: new Container(
                                          width: 500.0,
                                          height: 300.0,
                                          child: showMap(),
                                        ),
                                      )
                                    ],
                                  )),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('CLOSE'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Color(0xFF72BB53)),
                      title: Text(hosp.telephone),
                      subtitle:
                          Text(ph, style: TextStyle(color: Colors.green[300])),
                      onTap: () {
                        _showPhDialog();
                      },
                    ),
                    Divider(
                      indent: 65.0,
                    ),
                    ListTile(
                      leading: Icon(Icons.print, color: Color(0xFF72BB53)),
                      title: Text(hosp.fax),
                      subtitle:
                          Text(fax, style: TextStyle(color: Colors.green[300])),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.mail, color: Color(0xFF72BB53)),
                      title: Text(hosp.email),
                      subtitle: Text(mail,
                          style: TextStyle(color: Colors.green[300])),
                      onTap: () {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Launching Mail'),
                        ));
                        launch('mailto:${hosp.email}');
                      },
                    ),
                    Divider(
                      indent: 65.0,
                    ),
                    ListTile(
                      leading: ImageIcon(new AssetImage("assets/icons/web.png"),
                          color: Color(0xFF72BB53)),
                      title: Text(hosp.website),
                      subtitle: Text(site,
                          style: TextStyle(color: Colors.green[300])),
                      onTap: () {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Launching Browser'),
                        ));
                        launch('https:${hosp.website}');
                      },
                    ),
                    Divider(
                      indent: 65.0,
                    ),
                    ListTile(
                      leading: ImageIcon(new AssetImage("assets/icons/fb.png"),
                          color: Color(0xFF72BB53)),
                      title: Text(hosp.facebook),
                      subtitle:
                          Text(fb, style: TextStyle(color: Colors.green[300])),
                      onTap: () {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Launching Browser'),
                        ));
                        launch('https:${hosp.facebook}');
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: _facility(),
                    )
                  ],
                )),
            childCount: 1));
  }
}
