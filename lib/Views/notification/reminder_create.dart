import 'dart:async';

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import '../../Database/database.dart';
import '../../Models/notification/reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'dart:ui';
import '../../Views/notification/reminder.dart';

class ReminderCreate extends StatefulWidget {
  final String language;
  ReminderCreate({this.language});
  @override
  _ReminderCreateState createState() =>
      _ReminderCreateState(language: language);
}

class _ReminderCreateState extends State<ReminderCreate> {
  final String language;
  _ReminderCreateState({this.language});
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  final reminderFormKey = GlobalKey<FormState>();
  final dateFormat = DateFormat("MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");
  final alertTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  final actionController = TextEditingController();
  final noteController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime date;
  TimeOfDay time;
  var reminderValue = '';
  var appTitle = 'Create Reminder';

  @override
  initState() {
    super.initState();
    print(language);
    _setLanguage(language);
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('launcher_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  _setLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        appTitle = 'သတိပေးပြုလုပ်ရန်';
      });
    }
  }

  Future _alert(String alert, String title, String note) async {
    var id = int.parse(alert
        .replaceAll("-", "")
        .replaceAll(":", "")
        .replaceAll(" ", "")
        .substring(4));
    var scheduledNotificationDateTime = alertTimeFormat.parse(alert);
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.Max);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(id, title, note,
        scheduledNotificationDateTime, platformChannelSpecifics);
    print("Noti On");
    print(scheduledNotificationDateTime);
  }

  radioValueChg(var value) {
    setState(() {
      reminderValue = value;
    });
  }

  _saveReminder() {
    if (reminderFormKey.currentState.validate()) {
      if (reminderValue == '') {
        final snackBar = SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(
            "Choose Type (Appointment or Reminder)",
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 2),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        reminderFormKey.currentState.save();
        var dbhelper = DBHelper();
        var reminder = Reminder();
        reminder.remindDate =
            date.toString().substring(0, date.toString().indexOf(' '));
        reminder.remindTime =
            time.toString().substring(10, time.toString().indexOf(")"));
        var alretString = reminder.remindDate + " " + reminder.remindTime;
        reminder.remindType = reminderValue;
        reminder.remindAction = actionController.text;
        reminder.remindNote = noteController.text;
        dbhelper.addReminder(reminder);
        actionController.clear();
        noteController.clear();
        setState(() {
          reminderValue = '';
          _alert(alretString, reminder.remindAction, reminder.remindNote);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ReminderList(
                        language: language,
                      )));
        });
        return true;
      }
    } else {
      return print("Failed to add reminder");
    }
  }

  Future<bool> _backHomeScreen() {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ReminderList(
                  language: language,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _backHomeScreen,
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReminderList(
                                language: language,
                              )));
                },
              ),
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                appTitle,
                style:
                    TextStyle(color: Theme.of(context).textTheme.title.color),
              ),
              iconTheme: Theme.of(context).iconTheme,
            ),
            body: new GestureDetector(
                onTap: () {
                  // call this method here to hide soft keyboard
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              child: Form(
              key: reminderFormKey,
              child: ListView(children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: DateTimePickerFormField(
                    onSaved: (value) => date = value,
                    validator: (value) => value == null ? 'Choose Date' : null,
                    dateOnly: true,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color),
                    format: dateFormat,
                    decoration: InputDecoration(
                        filled: true,
                        hasFloatingPlaceholder: false,
                        fillColor: Theme.of(context).primaryColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        labelText: 'Date',
                        labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.title.color),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).textTheme.title.color,
                        )),
                    onChanged: (dt) => setState(() => date = dt),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TimePickerFormField(
                    validator: (value) => value == null ? 'Choose Time' : null,
                    onSaved: (value) => time = value,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color),
                    format: timeFormat,
                    decoration: InputDecoration(
                        filled: true,
                        hasFloatingPlaceholder: false,
                        fillColor: Theme.of(context).primaryColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        labelText: 'Time',
                        labelStyle: TextStyle(
                            color: Theme.of(context).textTheme.title.color),
                        prefixIcon: Icon(
                          Icons.timer,
                          color: Theme.of(context).textTheme.title.color,
                        )),
                    onChanged: (dt) => setState(() => time = dt),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Radio(
                        activeColor: Theme.of(context).primaryColor,
                        value: 'Reminder',
                        groupValue: reminderValue,
                        onChanged: radioValueChg,
                      ),
                    ),
                    Container(
                      child: Text(
                        'Reminder',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18.0),
                      ),
                    ),
                    Container(
                      child: Radio(
                        activeColor: Theme.of(context).primaryColor,
                        value: 'Appointment',
                        groupValue: reminderValue,
                        onChanged: radioValueChg,
                      ),
                    ),
                    Container(
                      child: Text(
                        'Appointment',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: Text(
                    "Action",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: TextFormField(
                    controller: actionController,
                    validator: (value) =>
                        value.length == 0 ? 'Action is required!' : null,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      filled: true,
                      hasFloatingPlaceholder: false,
                      fillColor: Theme.of(context).primaryColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 6.0),
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: Text(
                    "Note",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: TextFormField(
                    maxLength: 100,
                    controller: noteController,
                    validator: (value) => noteController.text.length == 0
                        ? 'Note is required!'
                        : null,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      filled: true,
                      hasFloatingPlaceholder: false,
                      fillColor: Theme.of(context).primaryColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    color: Theme.of(context).primaryColor,
                    onPressed: _saveReminder,
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.title.color,
                          fontSize: 16.0),
                    ),
                  ),
                )
              ]),
            ),
            ),
          );
        },
      ),
    );
  }
}
