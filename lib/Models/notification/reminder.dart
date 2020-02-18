class Reminder {
  int remindID;
  DateTime timeStamp;
  String remindDate;
  String remindTime;
  String remindType;
  String remindAction;
  String remindNote;

  Reminder(
      {this.remindID,
      this.timeStamp,
      this.remindDate,
      this.remindTime,
      this.remindType,
      this.remindAction,
      this.remindNote});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["remind_id"] = remindID;
    map["remind_date"] = remindDate;
    map["remind_time"] = remindTime;
    map["remind_type"] = remindType;
    map["remind_action"] = remindAction;
    map["remind_note"] = remindNote;
    return map;
  }
}
