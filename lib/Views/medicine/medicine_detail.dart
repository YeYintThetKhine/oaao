import 'package:flutter/material.dart';
import '../../Models/medicine/medicine.dart';

class MedicineDetail extends StatefulWidget {
  final Medicine medicine;
  MedicineDetail({this.medicine});
  @override
  _MedicineDetailState createState() =>
      _MedicineDetailState(medicine: medicine);
}

class _MedicineDetailState extends State<MedicineDetail> {
  final Medicine medicine;
  _MedicineDetailState({this.medicine});
  List<String> manufactures = [];

  @override
  void initState() {
    super.initState();
    _split();
  }

  _split() {
    manufactures = medicine.medManuf.replaceAll(" ", "").split(',');
  }

  Widget _manufactureWidgets(List<String> manufact) {
    List<Widget> manufactList = new List<Widget>();
    for (String manufact in manufactures) {
      manufactList.add(Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          manufact,
          style: TextStyle(fontSize: 16.0),
        ),
      ));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: manufactList);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                iconTheme: Theme.of(context).iconTheme,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    title: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    medicine.medNameEN,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textTheme.title.color),
                  ),
                )),
              ),
              new SliverList(
                  delegate: new SliverChildBuilderDelegate(
                      (context, index) => Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(
                                        left: 10.0, top: 18.0, bottom: 25.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 14.0),
                                          child: Image.network(
                                            medicine.medImg,
                                            height: 138.0,
                                            width: 138.0,
                                          ),
                                        ),
                                        ListTile(
                                          title: Padding(
                                            padding: EdgeInsets.only(
                                                top: 5.0, bottom: 5.0),
                                            child: Text(
                                              "${medicine.medNameEN}\n${medicine.medNameMM}",
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Name",
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 5.0),
                                            child: Text(
                                              "manufacture".toUpperCase(),
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 16.0, bottom: 6.0),
                                          width: 128.0,
                                          height: 1.5,
                                          color: Colors.black54,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.0,
                                              top: 5.0,
                                              right: 50.0),
                                          child:
                                              _manufactureWidgets(manufactures),
                                        ),
                                        Divider(),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 16.0,
                                              top: 10.0,
                                              bottom: 10.0),
                                          child: Text(
                                            "description".toUpperCase(),
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 16.0, bottom: 6.0),
                                          width: 128.0,
                                          height: 1.5,
                                          color: Colors.black54,
                                        ),
                                        ListTile(
                                          title: Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0),
                                            child: Text(
                                              medicine.medDesc,
                                              style: TextStyle(
                                                  fontSize: 16.0, height: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                      childCount: 1))
            ],
          ),
        );
      },
    );
  }
}
