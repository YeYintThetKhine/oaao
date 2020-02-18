import 'package:meta/meta.dart';
//Kaung Myat 2/8/2018
//model and lists which will retrieve data from json

//Model for retrieving hospital data
class Clinic {
  Clinic({
    this.id,
    this.clinicimg,
    this.nameEN,
    this.nameMM,
    this.location,
    this.telephone,
    this.fax,
    this.email,
    this.website,
    this.facebook,
    this.type,
    this.map,
  });

  final String id;
  final String clinicimg;
  final String nameEN;
  final String nameMM;
  final String location;
  final String telephone;
  final String fax;
  final String email;
  final String website;
  final String facebook;
  final String type;
  final String map;
}

//Model for retrieving hospital facility and services
class FacilityService {
  FacilityService({@required this.servicename});

  final String servicename;
}

//Model for retrieving hospital types
class HType {
  final String title;
  final int count;
  const HType({@required this.title, this.count});
}
