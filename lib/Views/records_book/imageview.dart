import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ShowImages extends StatefulWidget {
  final i;
  final imgdata;

  ShowImages({this.i,@required this.imgdata});
  _ShowImagesState createState() => _ShowImagesState(i: i,imgdata: imgdata);
}

class _ShowImagesState extends State<ShowImages> {
  var i;
  var imgdata;

  _ShowImagesState({this.i,@required this.imgdata});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children: <Widget>[
          
        PhotoView(
          maxScale: 3.0,
        imageProvider: MemoryImage(imgdata),
      ),
      InkWell(
        child: Container(
          padding: EdgeInsets.only(left: 14.0,top: 32.0),
        child: CircleAvatar(
          radius: 24.0,
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back),
        ),
      ),
      onTap: (){
        Navigator.pop(context);
      },
      )
        ],
      )
    );
  }
}
class CustomAppBar extends State<AppBar>{
  @override
  Widget build(BuildContext context){
    return Container(
      height: 150,
    );
  }
}