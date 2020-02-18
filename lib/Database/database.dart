import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/records_book/record_book.dart';
import '../Models/notification/reminder.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "profiles.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _create);
    return theDb;
  }

  // Creating a tables, Users and Medical Records with fields
  void _create(Database db, int version) async {
    // When creating the db, create the table
    await db.execute("""CREATE TABLE user(
      id INTEGER PRIMARY KEY autoincrement,
      name TEXT NOT NULL UNIQUE)""");

    await db.execute("""CREATE TABLE records(
      rec_id TEXT UNIQUE NOT NULL,
      user_id INTEGER NOT NULL,
      doctor TEXT NOT NULL,
      hospital TEXT NOT NULL,
      problem TEXT NOT NULL,
      date TEXT NOT NULL,
      rec_order INTEGER PRIMARY KEY AUTOINCREMENT,
      FOREIGN KEY (user_id) REFERENCES user(id))""");

    print("Created tables");

    await db.execute("""CREATE TABLE reminder(
      remind_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      remind_date TEXT NOT NULL,
      remind_time TEXT NOT NULL,
      remind_type TEXT NOT NULL,
      remind_action TEXT NOT NULL,
      remind_note TEXT NOT NULL
    )
    """);

    await db.execute("""CREATE TABLE recordImages(
      user_id INTEGER NOT NULL,
      rec_id TEXT NOT NULL,
      imgData BLOB NOT NULL
    )
    """);
  }

  //Add Reminder Records
  void addReminder(Reminder remind) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      print("Reminder Added to DB");
      return await txn.insert("reminder", remind.toMap());
    });
  }

  Future<int> getCount() async {
    var dbClient = await db;
    var count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM user'));
    return count;
  }

  //Profile add function
  Future<void> addUser(User user) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.insert("user", user.toMap());
    });
  }

  void addImages(ImageData imgData) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.insert("recordImages", imgData.toMap());
    });
    print(
        'user id = ${imgData.userid} rec id = ${imgData.recid} image data = ${imgData.imgData}');
  }

  //Retrieve Profiles from database
  Future<List<User>> fetchUserList() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM user');
    List<User> users = new List();
    for (int i = 0; i < list.length; i++) {
      users.add(new User(id: list[i]["id"], name: list[i]["name"]));
    }
    return users;
  }

  //Retrieve Reminder from database
  Future<List<Reminder>> getReminderList() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM reminder');
    List<Reminder> reminderList = List();
    for (var i = 0; i < list.length; i++) {
      reminderList.add(Reminder(
          remindID: list[i]['remind_id'],
          remindDate: list[i]['remind_date'],
          remindTime: list[i]['remind_time'],
          remindType: list[i]['remind_type'],
          remindAction: list[i]['remind_action'],
          remindNote: list[i]['remind_note']));
    }
    return reminderList;
  }

  //Update user from database
  void updateReminder(Reminder reminder) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.update("reminder", reminder.toMap(),
          where: "remind_id = ?", whereArgs: [reminder.remindID]);
    });
  }

  //Delete User from database
  void deleteReminder(int id) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete("reminder", where: "remind_id = ?", whereArgs: [id]);
    });
  }

  //Delete User from database
  void deleteUser(int id) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete("user", where: "id = ?", whereArgs: [id]);
      await txn.delete("records", where: "user_id = ?", whereArgs: [id]);
    });
  }

  //Update user from database
  void updateUser(User user) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn
          .update("user", user.toMap(), where: "id = ?", whereArgs: [user.id]);
    });
  }

  //Medical Records add function
  void addRecord(Records rec) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.insert("records", rec.toMap());
    });
  }

  Future<List<ImageData>> fetchImageDataList({int userid, String recid}) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM recordImages WHERE user_id = $userid AND rec_id = '$recid'");
    List<ImageData> records = new List();
    for (int i = 0; i < list.length; i++) {
      records.add(ImageData(
        recid: list[i]["rec_id"],
        userid: list[i]["user_id"],
        imgData: list[i]["imgData"],
      ));
    }
    return records;
  }

  //Retrieve Medical Records from database
  Future<List<Records>> fetchRecordsList({int userid, String order}) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM records WHERE user_id = $userid ORDER BY rec_order $order");
    List<Records> records = new List();
    for (int i = 0; i < list.length; i++) {
      records.add(Records(
        recid: list[i]["rec_id"],
        userid: list[i]["user_id"],
        doctor: list[i]["doctor"],
        hospital: list[i]["hospital"],
        problem: list[i]["problem"],
        date: list[i]["date"],
      ));
    }
    return records;
  }

  Future<Records> fetchaRecord(int userid, String recid) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM records WHERE user_id = $userid AND rec_id = '$recid'");
    List<Records> records = new List();
    for (int i = 0; i < list.length; i++) {
      records.add(Records(
          recid: list[i]["rec_id"],
          userid: list[i]["user_id"],
          doctor: list[i]["doctor"],
          hospital: list[i]["hospital"],
          problem: list[i]["problem"],
          date: list[i]["date"]));
    }
    Records displayrec = records.elementAt(0);
    return displayrec;
  }

  //Delete Medical Records from database
  void deleteRecord(String recid) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn
          .delete("records", where: "rec_id = ?", whereArgs: [recid]);
    });
    await dbClient.transaction((txn) async {
      return await txn
          .delete("recordImages", where: "rec_id = ?", whereArgs: [recid]);
    });
  }

  //Update Medical Records from database
  void updateRecords(Records rec) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.update("records", rec.toMap(),
          where: "rec_id = ?", whereArgs: [rec.recid]);
    });
  }

  void updateImages({ImageData imgData, recid}) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn
          .delete("recordImages", where: "rec_id = ?", whereArgs: [recid]);
    });
    await dbClient.transaction((txn) async {
      return await txn.insert("recordImages", imgData.toMap());
    });
  }

  //close database
  closeDB() async {
    var dbClient = await db;
    dbClient.close();
  }
}
