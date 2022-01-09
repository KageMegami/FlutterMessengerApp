import 'package:fl2_project/component/display_conversation.dart';
import 'package:fl2_project/model/conversation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl2_project/server_connect.dart';
import 'package:fl2_project/model/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool _isLoginCallBackRegistered = false;

  void _handleMessage(RemoteMessage message) {
    if (message.data["type"] == "message" ) {
      Conversation conversation = context.read<ServerConnect>().conversations.firstWhere((element) => element.id == message.data["conversationId"]);
      context.read<ServerConnect>().getConversationMessages(conversation.id);
      Navigator.of(context).popUntil(ModalRoute.withName("/home"));
      Navigator.of(context).pushNamed('/conversation', arguments: conversation);
    }
    if (message.data["type"] == "friend" ) {
      context.read<ServerConnect>().getUserConversations();
      context.read<ServerConnect>().getUserFriends();
    }
    if (message.data["type"] == "friendRequest" ) {
      context.read<ServerConnect>().getFriendRequest();
      Navigator.of(context).popUntil(ModalRoute.withName("/home"));
      Navigator.of(context).pushNamed('/friends');
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data["type"] == "message" ) {
        Message newMessage = Message(
            message.data["id"], message.data["senderId"],
            message.data["content"]);
        context.read<ServerConnect>().addRecievedMessage(
            newMessage, message.data["conversationId"]);
      }
      if (message.data["type"] == "friend" ) {
        context.read<ServerConnect>().getUserConversations();
      }
      if (message.data["type"] == "friendRequest" ) {
        context.read<ServerConnect>().getFriendRequest();
      }
    });
  }

  Future<void> _loadUserData(BuildContext context) async {
    context.read<ServerConnect>().getUser().then((user) async {
      if (user == null) {
        Navigator.of(context).pushNamed("/user", arguments: true).then((value) => _loadUserData(context));
      } else {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? token = await messaging.getToken();
        if (token != null) {
          context.read<ServerConnect>().updateToken(token);
        }
        context.read<ServerConnect>().getUserConversations();
        context.read<ServerConnect>().getUserFriends();
        context.read<ServerConnect>().getFriendRequest();
      }
    });
  }

  _checkLoggin(BuildContext context) {
    if (!_isLoginCallBackRegistered) {
      _isLoginCallBackRegistered = true;
      FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
        if (user != null) {
          final idToken = await user.getIdToken();
          context.read<ServerConnect>().setToken(idToken);
        }
      });
      FirebaseAuth.instance.userChanges().listen((User? user) async {
        if (user == null) {
          context.read<ServerConnect>().clear();
          Navigator.of(context).pushNamed('/login');
        } else {
          final idToken = await user.getIdToken();
          context.read<ServerConnect>().setToken(idToken);
          Navigator.of(context).popUntil(ModalRoute.withName("/home"));
          _loadUserData(context);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    _checkLoggin(context);
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.red,
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(color: Colors.black)),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pushNamed("/user", arguments: false).then((value) => setState(() => {}));
                },
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.black),
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: context.watch<ServerConnect>().conversations.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/conversation", arguments: context.read<ServerConnect>().conversations[index]);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                left: 14.5,
                                top: 12,
                                child: context.read<ServerConnect>().conversations[index].urlPicture != null ? Image.network(context.watch<ServerConnect>().conversations[index].urlPicture!, height: 63.0, width: 63.0) : Image.asset("images/default_picture.jpg", height: 60.0, width: 60.0)),
                              Image.asset("images/cadre.png", height: 90.0, width: 90.0)
                            ]
                          ),
                          DisplayConversation(conversation: context.read<ServerConnect>().conversations[index])
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset("images/chats.png", height: 60),
                    TextButton(onPressed: () => Navigator.of(context).pushNamed("/friends"), child: Image.asset("images/friends.png", height: 90)),
                  ],
                ),
                padding: const EdgeInsets.only(bottom: 10),
              )
            ],
          ),
        )
      );
  }
}