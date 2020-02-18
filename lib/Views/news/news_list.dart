import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/landing_page/news.dart';
import 'package:intl/intl.dart';
import '../../Animations/slide_up_in.dart';
import '../../Views/news/news.dart';

class NewsList extends StatefulWidget {
  final String language;
  NewsList({this.language});
  @override
  _NewsListState createState() => _NewsListState(language: language);
}

class _NewsListState extends State<NewsList> {
  final String language;
  _NewsListState({this.language});
  var title = 'New List';
  List<News> newsList = [];
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  var _isLoading = true;
  var dateformat = DateFormat("dd MMMM y");
  List<DateTime> dateList = [];

  @override
  void initState() {
    _setLanguage(language);
    super.initState();
    _getNewsList();
  }

  _setLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        title = 'သတင်းများ';
      });
    }
  }

  _getNewsList() {
    dbRef.child('news').once().then((snapsnot) {
      var keys = snapsnot.value.keys;
      var data = snapsnot.value;
      for (var item in keys) {
        News news = News(
          newsDate: DateTime.fromMillisecondsSinceEpoch(
              int.parse('${data[item]['date']}000')),
          newsTitleEN: data[item]['heading_en'],
          newsTitleMM: data[item]['heading_mm'],
          newsContent: data[item]['desc'],
          newsImg: data[item]['img'],
        );
        newsList.add(news);
        newsList.sort((a, b) => a.newsDate.compareTo(b.newsDate));
        newsList = newsList.reversed.toList();
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    var actualHeight = device.height - 24 - kToolbarHeight;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
            appBar: AppBar(
              iconTheme: Theme.of(context).iconTheme,
              title: Text(
                title,
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
            body: _isLoading == false
                ? GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: device.height > 600 &&
                            orientation == Orientation.portrait
                        ? (device.width / 2) / (actualHeight / 4)
                        : device.height < 600 &&
                                orientation == Orientation.portrait
                            ? (device.width / 2) / (actualHeight / 3)
                            : (device.width / 2) / (actualHeight / 2),
                    children: List.generate(newsList.length, (index) {
                      return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 6.0),
                              child: FlatButton(
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      SlideFromBottomAnimation(
                                          widget: NewsPage(
                                        news: newsList[index],
                                        language: language,
                                        appbarTitle:
                                            language == 'en' ? "News" : 'သတင်း',
                                      )));
                                },
                                child: Container(
                                  width: device.width / 2 - 12,
                                  height: device.height > 600 &&
                                          orientation == Orientation.portrait
                                      ? actualHeight / 4 - 12
                                      : device.height < 600 &&
                                              orientation ==
                                                  Orientation.portrait
                                          ? actualHeight / 3 - 12
                                          : actualHeight / 2 - 12,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.network(
                                        newsList[index].newsImg,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      )),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 6.0),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(114, 187, 83, 0.9),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0)),
                              ),
                              height: device.height > 600 &&
                                      orientation == Orientation.portrait
                                  ? (actualHeight / 4 - 12) / 1.7
                                  : device.height < 600 &&
                                          orientation == Orientation.portrait
                                      ? (actualHeight / 3 - 12) / 2
                                      : (actualHeight / 2 - 12) / 2,
                              child: FlatButton(
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      SlideFromBottomAnimation(
                                          widget: NewsPage(
                                        news: newsList[index],
                                        language: language,
                                        appbarTitle:
                                            language == 'en' ? "News" : 'သတင်း',
                                      )));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text(
                                        "${newsList[index].newsTitleEN}\n${newsList[index].newsTitleMM}",
                                        textAlign: TextAlign.center,
                                        maxLines:
                                            orientation == Orientation.landscape
                                                ? 1
                                                : 2,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: language == 'en' &&
                                                    device.height < 600
                                                ? 14.0
                                                : language == 'en' &&
                                                        device.height > 600
                                                    ? 16.0
                                                    : 12.0),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      padding: const EdgeInsets.only(
                                          top: 8.0, right: 12.0),
                                      child: Text(
                                        dateformat
                                            .format(newsList[index].newsDate)
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize:
                                                language == 'en' ? 12.0 : 12.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]);
                    }),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor),
                    ),
                  ));
      },
    );
  }
}
