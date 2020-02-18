import 'package:flutter/material.dart';
import '../../Models/landing_page/news.dart';
import 'package:intl/intl.dart';

class NewsPage extends StatefulWidget {
  final News news;
  final String language;
  final String appbarTitle;
  NewsPage({this.news, this.language, this.appbarTitle});
  @override
  _NewsPageState createState() =>
      _NewsPageState(news: news, language: language);
}

class _NewsPageState extends State<NewsPage> {
  final News news;
  final String language;
  final String appbarTitle;
  _NewsPageState({this.news, this.language, this.appbarTitle});
  var dateformat = DateFormat("dd MMMM y");
  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            title: Text(
              language == 'mm' ? "သတင်း" : 'News',
              style: TextStyle(color: Theme.of(context).textTheme.title.color),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, i) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 200,
                              child: Image.network(
                                news.newsImg,
                                color: Color.fromRGBO(114, 187, 83, 1.0),
                                colorBlendMode: BlendMode.softLight,
                                fit: BoxFit.cover,
                                width: device.width,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                dateformat.format(news.newsDate),
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(
                                height: 1.5,
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Text(
                                "${news.newsTitleEN}\n${news.newsTitleMM}"
                                    .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: 12.0, bottom: 8.0, top: 8.0),
                              color: Theme.of(context).primaryColor,
                              width: 35.0,
                              height: 5.0,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                news.newsContent,
                                textAlign: TextAlign.justify,
                                style: TextStyle(fontSize: 16.0, height: 1.25),
                              ),
                            ),
                          ],
                        ),
                    childCount: 1),
              ),
            ],
          ),
        );
      },
    );
  }
}
