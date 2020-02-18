import 'package:flutter/material.dart';
import '../../Auth/auth.dart';
import '../../Views/landing_page/login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/ask_chat/chat.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  final String language;
  final String appbarTitle;
  final AuthFunction authFunction;
  ChatRoom({this.appbarTitle, this.language, this.authFunction});
  @override
  _ChatRoomState createState() =>
      _ChatRoomState(appbarTitle: appbarTitle, language: language);
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  final String language;
  final String appbarTitle;
  _ChatRoomState({this.appbarTitle, this.language});
  AuthStatus authStatus = AuthStatus.notSignedIn;
  final List<ChatMessagesArea> _messages = <ChatMessagesArea>[];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isEmpty = false;
  String userId = '';
  String email = '';
  List<Chat> chatList = <Chat>[];
  Chat chat;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  StreamSubscription<Event> msgSubscription;
  String notSignedIn = 'You are not signed in!';
  String login = 'Login';
  var dateTimeFormat = DateFormat("yyyy-MM-d HH:mm:ss");

  @override
  void initState() {
    super.initState();
    _changeLanguage(language);
    widget.authFunction.getUser().then((user) {
      if (user == null) {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      } else if (user == "Not Verified User") {
        setState(() {
          authStatus = AuthStatus.notSignedIn;
        });
      } else {
        setState(() {
          authStatus = AuthStatus.signedIn;
          widget.authFunction.getEmail().then((value) {
            setState(() {
              email = value;
            });
          });
          userId = user;
          msgSubscription = dbRef
              .child('chat')
              .child('users')
              .child(userId)
              .onChildChanged
              .listen((Event event) {
            ChatMessagesArea message = new ChatMessagesArea(
              sender: event.snapshot.value['sender'],
              animationController: AnimationController(
                duration: Duration(milliseconds: 300),
                vsync: this,
              ),
            );
            setState(() {
              _messages.insert(0, message);
            });
            message.animationController.forward();
          });
          dbRef
              .child('chat')
              .child('users')
              .child(userId)
              .once()
              .then((DataSnapshot snap) {
            if (snap.value != null) {
              var ids = snap.value.keys;
              var data = snap.value;
              for (var id in ids) {
                chat = new Chat(
                  sender: data[id]['sender'],
                  postDate: data[id]['postDate'],
                  timeStamp: DateTime.parse(data[id]['postDate']),
                  text: data[id]['text'],
                );
                chatList.add(chat);
              }
              chatList.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
            }
            _showChatBox(chatList);
          });
        });
      }
    });
  }

  _changeLanguage(String lan) {
    if (lan == 'mm') {
      setState(() {
        notSignedIn = 'အကောင့်မဝင်ထားပါ';
        login = 'အကောင့်ဝင်ရန်';
      });
    }
  }

  _showChatBox(List<Chat> dataList) {
    for (var item in dataList) {
      ChatMessagesArea message = new ChatMessagesArea(
        message: item.text,
        sender: item.sender,
        animationController: AnimationController(
          duration: Duration(milliseconds: 200),
          vsync: this,
        ),
      );
      setState(() {
        _messages.insert(0, message);
      });
      message.animationController.forward();
    }
  }

  @override
  void dispose() {
    for (ChatMessagesArea messagesArea in _messages) {
      messagesArea.animationController.dispose();
    }
    super.dispose();
    try {
      msgSubscription.cancel();
    } catch (e) {}
  }

  void _handleSubmitted(String text) {
    var chatForm = <String, dynamic>{
      'sender': email,
      'postDate': DateTime.now().toString(),
      'text': text,
    };
    dbRef.child('chat').child('users').child(userId).push().set(chatForm);
    _textEditingController.clear();
    setState(() {
      _isEmpty = false;
    });
    ChatMessagesArea message = new ChatMessagesArea(
      message: text,
      sender: email,
      animationController: AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  Widget _textSender() {
    return new Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: _textEditingController,
                onSubmitted: _handleSubmitted,
                onChanged: (String msg) {
                  setState(() {
                    _isEmpty = msg.length > 0;
                  });
                },
                decoration: InputDecoration.collapsed(
                    hintText: language == 'mm'
                        ? "မက်ဆေ့ချ်ပို့ရန်"
                        : "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: _isEmpty == true
                      ? Theme.of(context).primaryColor
                      : Color(0xFF888888),
                ),
                onPressed: _isEmpty == true
                    ? () => _handleSubmitted(_textEditingController.text)
                    : null,
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return Scaffold(
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    notSignedIn,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen(
                                  authFunction: Authentic(),
                                  language: language,
                                )));
                  },
                  child: Text(
                    login,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color),
                  ),
                )
              ],
            ),
          ),
        );
      case AuthStatus.signedIn:
        return OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(
                  appbarTitle,
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
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          reverse: true,
                          itemBuilder: (_, int index) => _messages[index],
                          itemCount: _messages.length,
                        ),
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      Container(
                        decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                        child: _textSender(),
                      )
                    ],
                  )),
            );
          },
        );
    }
  }
}

class ChatMessagesArea extends StatelessWidget {
  final String message;
  final String sender;
  final AnimationController animationController;
  ChatMessagesArea({this.message, this.animationController, this.sender});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Column(
        children: [
          sender != 'bot'
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            new Container(
                              margin: const EdgeInsets.only(left: 12.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(60, 179, 113, 1),
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: new Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color:
                                        Theme.of(context).textTheme.title.color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 8.0),
                        child: new CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).textTheme.title.color,
                            )),
                      ),
                    ],
                  ),
                )
              : Container(),
          sender == 'bot'
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      new Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: new CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).textTheme.title.color,
                            )),
                      ),
                      Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              margin: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(60, 179, 113, 1),
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: new Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color:
                                        Theme.of(context).textTheme.title.color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
