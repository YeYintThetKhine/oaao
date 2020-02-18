import 'package:flutter/material.dart';
import '../../Models/records_book/record_book.dart';
import '../../Database/database.dart' as dbhelper;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:multi_image_picker/asset.dart';
import 'package:flutter/services.dart';



class ImagesEdit extends StatefulWidget {
  
  final imglist;
  final record;
  final lan;
  
  ImagesEdit({@required this.imglist,@required this.record,@required this.lan});

  _ImagesEditState createState() => _ImagesEditState(imglist: imglist,record: record,lan:lan);
}

class _ImagesEditState extends State<ImagesEdit> {
  List<ImageData> imglist;
  Records record;
  final lan;

  _ImagesEditState({@required this.imglist,@required this.record,@required this.lan});

  var txtStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold
  );

  @override
  void dispose() { 
    super.dispose();
  }

  var db = dbhelper.DBHelper();
  bool _submit(){
    for(ImageData imgData in imglist){
      db.updateImages(
        imgData: imgData,
        recid:record.recid
      );
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    
    List<Asset> images = List();
    List<ImageData> multiPicks = List();

    showOptionMultiPick() async{

    List resultList;
    List<ImageData> pickList = List();

    setState(() {
          pickList = List();
        });

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: false,
      );
    } on PlatformException catch (e) {
      print(e.message);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
    if(images.length!=0){
      for(Asset asset in images){
      await asset.requestOriginal(quality: 30);
      var a = ImageData(
          userid: record.userid,
          recid: record.recid,
          imgData: asset.imageData.buffer.asUint8List()
        );
      pickList.add(a);
    }
    setState(() {
          multiPicks = pickList;
          for(ImageData imgss in multiPicks){
            imglist.add(imgss);
          }
        });
    }
    }

    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF72BB53),
        child: Icon(Icons.add_photo_alternate,color:Colors.white),
        onPressed: () async{
          await showOptionMultiPick();
}),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(lan=='en'?'Confirm':'အတည်ပြု',
            style:TextStyle(
              color: Colors.white,
              fontSize: 16.0
            )
            ),
            onPressed: (){
              setState(() {
                if(_submit()==true){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        content: new Text("Changes have been saved",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          new FlatButton(
                            child: new Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }                             
              });
            },
          )
        ],
      ),
      body:GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3
        ),
        itemCount: imglist.length,
        itemBuilder: (context,index){
            return GridTile(
              header: IconButton(
                color: Colors.red,
                alignment: Alignment.topRight,
                onPressed: (){
                  setState(() {
                    imglist.removeAt(index);
                                    });
                },
                icon:Icon(Icons.cancel)
              ),
              child:Image.memory(imglist[index].imgData,fit: BoxFit.cover,),
            );
        },
      ),
    ); 
  }
}



