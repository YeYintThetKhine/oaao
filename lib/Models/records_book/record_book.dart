import 'dart:typed_data';

class User {
  int id;
  String name;

  User({this.id, this.name});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    return map;
  }

  static final columns = ["id", "name"];
}

class Records {
  String recid;
  int userid;
  String doctor;
  String hospital;
  String problem;
  String date;

  Records({
    this.recid,
    this.userid,
    this.doctor,
    this.hospital,
    this.problem,
    this.date,
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["rec_id"] = recid;
    map["user_id"] = userid;
    map["doctor"] = doctor;
    map["hospital"] = hospital;
    map["problem"] = problem;
    map["date"] = date;

    return map;
  }
}

class ImageData {
  int userid;
  String recid;
  Uint8List imgData;

  ImageData({this.userid, this.recid, this.imgData});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["user_id"] = userid;
    map["rec_id"] = recid;
    map["imgData"] = imgData;

    return map;
  }
}
