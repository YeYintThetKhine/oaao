import 'package:flutter/material.dart';
import 'reminder_create.dart';
import '../../Animations/slide_right_in.dart';
import '../../Database/database.dart';
import 'dart:async';
import '../../Models/notification/reminder.dart';
import 'package:intl/intl.dart';
import 'reminder_edit.dart';
import '../../Views/landing_page/home_screen.dart';
import '../../Auth/auth.dart';

class ReminderSettingEN {
  static const String edit = 'Edit';
  static const String delete = 'Delete';

  static const List<String> options = <String>[edit, delete];
}

class ReminderSettingMM {
  static const String edit = 'ပြုပြင်မည်';
  static const String delete = 'ဖျက်သိမ်းမည်';

  static const List<String> options = <String>[edit, delete];
}

Future<List<Reminder>> reminderData() async {
  var dbHelper = DBHelper();
  Future<List<Reminder>> reminders = dbHelper.getReminderList();
  return reminders;
}

class ReminderList extends StatefulWidget {
  final String language;
  ReminderList({this.language});
  @override
  _ReminderListState createState() => _ReminderListState(language: language);
}

abstract class ListItem {}

class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);
}

class MessageItem implements ListItem {
  final int id;
  final DateTime timeStamp;
  final String date;
  final String time;
  final String action;
  final String note;
  final String type;

  MessageItem(this.id, this.timeStamp, this.date, this.time, this.action,
      this.note, this.type);
}

class _ReminderListState extends State<ReminderList> {
  final String language;
  _ReminderListState({this.language});
  List<ListItem> items = [];
  List<String> dateList = [];
  List<String> timeList = [];
  List<DateTime> intDate = [];
  List<Reminder> reminderList = [];
  Future<List<Reminder>> remind;
  var appTitle = 'Reminder List';
  var noReminder = 'No Reminder';
  var delBoxTitle = 'Delete Reminder';
  var delBoxText = 'Are you sure you want to delete?';
  var delBoxYes = 'Yes';
  var delBoxNo = 'No';
  final dateFormat = DateFormat("yyyy-MM-dd H:mm");

  @override
  void initState() {
    super.initState();
    _changeLanguage(language);
    remind = reminderData();
    remind.then((data) {
      for (var i = 0; i < data.length; i++) {
        var reminder = Reminder(
          remindID: data[i].remindID,
          timeStamp:
              dateFormat.parse(data[i].remindDate + " " + data[i].remindTime),
          remindDate: data[i].remindDate,
          remindTime: data[i].remindTime,
          remindType: data[i].remindType,
          remindAction: data[i].remindAction,
          remindNote: data[i].remindNote,
        );
        reminderList.add(reminder);
      }
      reminderList.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      for (var i = 0; i < reminderList.length; i++) {
        intDate.add(dateFormat.parse(
            reminderList[i].remindDate + " " + reminderList[i].remindTime));
      }
      _sortnSplit();
      for (var item in dateList.toSet().toList()) {
        items.add(HeadingItem(item));
        for (var i = 0; i < reminderList.length; i++) {
          if (item == reminderList[i].remindDate) {
            items.add(MessageItem(
                reminderList[i].remindID,
                dateFormat.parse(reminderList[i].remindDate +
                    " " +
                    reminderList[i].remindTime),
                reminderList[i].remindDate,
                reminderList[i].remindTime,
                reminderList[i].remindAction,
                reminderList[i].remindNote,
                reminderList[i].remindType));
          }
        }
      }
    });
  }

  _changeLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        appTitle = "သတိပေးချက်များ";
        noReminder = 'သတိပေးချက်များမရှိပါ';
        delBoxTitle = 'သတိပေးဖျက်ရန်';
        delBoxText = 'သတိပေးဖျက်ရန်သေချာပါသလား?';
        delBoxYes = 'လုပ်ဆောင်မည်';
        delBoxNo = 'မလုပ်ဆောင်ပါ';
      });
    }
  }

  _sortnSplit() {
    for (var date in intDate) {
      dateList.add(date.toString().substring(0, date.toString().indexOf(' ')));
    }
  }

  _showReminderDetail(MessageItem index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              index.action,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 22.0),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  leading: Icon(
                    Icons.date_range,
                    color: Theme.of(context).primaryColor,
                    size: 28.0,
                  ),
                  title: Text(index.date),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  leading: Icon(
                    Icons.timelapse,
                    color: Theme.of(context).primaryColor,
                    size: 28.0,
                  ),
                  title: Text(index.time),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  leading: Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).primaryColor,
                    size: 36.0,
                  ),
                  title: Text(index.type),
                ),
                Flexible(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0.0),
                    leading: Icon(
                      Icons.comment,
                      color: Theme.of(context).primaryColor,
                      size: 36.0,
                    ),
                    title: Text(index.note),
                  ),
                ),
              ],
            ),
          );
        });
  }

  _options(MessageItem reminder, String value) {
    Reminder remindermodel = Reminder(
        remindID: reminder.id,
        remindDate: reminder.date,
        remindTime: reminder.time,
        remindType: reminder.type,
        remindAction: reminder.action,
        remindNote: reminder.note);
    if (value == "Delete" || value == "ဖျက်သိမ်းမည်") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            var device = MediaQuery.of(context).size;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text(delBoxTitle,
                  style: TextStyle(
                    color: Color(0xFF333333),
                  )),
              content: Text(
                delBoxText,
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: device.height > 600 ? 18.0 : 14.0),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    DBHelper dh = new DBHelper();
                    setState(() {
                      dh.deleteReminder(reminder.id);
                      remind = reminderData();
                    });
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ReminderList(
                                  language: language,
                                )));
                  },
                  child: Text(
                    delBoxYes,
                    style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: device.height > 600 ? 18.0 : 14.0),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    delBoxNo,
                    style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: device.height > 600 ? 18.0 : 14.0),
                  ),
                )
              ],
            );
          });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReminderEdit(
                    reminder: remindermodel,
                    language: language,
                  )));
    }
  }

  Future<bool> _backHomeScreen() {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(
                  language: language,
                  authFunction: Authentic(),
                )));
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientation) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return WillPopScope(
              onWillPop: _backHomeScreen,
              child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      language: language,
                                      authFunction: Authentic(),
                                    )));
                      },
                    ),
                    iconTheme: Theme.of(context).iconTheme,
                    title: Text(
                      appTitle,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  body: FutureBuilder<List<Reminder>>(
                      future: reminderData(),
                      builder: (context, snapShot) {
                        if (snapShot.hasData && snapShot.data.length != 0) {
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              if (item is HeadingItem) {
                                return Container(
                                  margin: EdgeInsets.only(top: 8.0),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.event_note,
                                      size: 32.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: Text(
                                      item.heading.toUpperCase(),
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                );
                              } else if (item is MessageItem) {
                                return Container(
                                  child: Container(
                                    margin: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color.fromRGBO(
                                                  114, 187, 83, 0.25),
                                              blurRadius: 10.0)
                                        ]),
                                    width: (device.width) - 24.0,
                                    child: FlatButton(
                                      highlightColor:
                                          Color.fromRGBO(255, 255, 255, 0.5),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        _showReminderDetail(items[i]);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10.0),
                                                    topLeft:
                                                        Radius.circular(10.0))),
                                            width: (device.width - 24.0) / 5,
                                            child: Column(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.alarm,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .title
                                                      .color,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Text(
                                                    item.time,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .title
                                                            .color),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                EdgeInsets.only(left: 12.0),
                                            width: (device.width - 24.0) / 2,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 4.0),
                                                    child: Text(
                                                      item.action,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: 16.0),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 4.0),
                                                    child: Text(
                                                      item.type,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF888888),
                                                          fontSize: 14.0),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            width: (device.width - 24.0) / 4,
                                            child: PopupMenuButton(
                                              onSelected: (String choice) {
                                                _options(item, choice);
                                              },
                                              icon: Icon(Icons.more_vert,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              itemBuilder:
                                                  (BuildContext context) {
                                                if (language == 'mm') {
                                                  return ReminderSettingMM
                                                      .options
                                                      .map((String option) {
                                                    return PopupMenuItem<
                                                        String>(
                                                      value: option,
                                                      child: Text(option),
                                                    );
                                                  }).toList();
                                                } else {
                                                  return ReminderSettingEN
                                                      .options
                                                      .map((String option) {
                                                    return PopupMenuItem<
                                                        String>(
                                                      value: option,
                                                      child: Text(option),
                                                    );
                                                  }).toList();
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } else {
                          return Center(
                              child: new Text(
                            noReminder,
                            style: TextStyle(fontSize: 18.0),
                          ));
                        }
                      }),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          SlideRightAnimation(
                              widget: ReminderCreate(
                            language: language,
                          )));
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.add),
                  )),
            );
          },
        );
      },
    );
  }
}
