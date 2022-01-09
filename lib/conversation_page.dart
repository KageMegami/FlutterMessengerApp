import 'dart:async';

import 'package:fl2_project/model/conversation.dart';
import 'package:fl2_project/component/display_message.dart';
import 'package:fl2_project/model/message.dart';
import 'package:fl2_project/model/user.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import 'package:fl2_project/server_connect.dart';

class MyConversationPage extends StatefulWidget {
  const MyConversationPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyConversationPageState createState() => _MyConversationPageState();
}

class _MyConversationPageState extends State<MyConversationPage> {
  String message = "";
  late Conversation conversation;
  var msgController = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1), () => _controller.jumpTo(_controller.position.maxScrollExtent));
    Timer(const Duration(milliseconds: 1600), () => _controller.jumpTo(_controller.position.maxScrollExtent));
  }

  _onMessage(String _message) {
    message = _message;
  }

  Widget addLink(int index) {
    User tmpUser =  context.read<ServerConnect>().user!;
    Message tmpMessage =  context.read<ServerConnect>().messages[conversation.id]![index];
    if (index == 0) {
      if (tmpMessage.senderId == tmpUser.id) {
        return Align(
          child: Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Image.asset("images/link_start_right.png", width: 260),
          ),
          alignment: Alignment.topCenter,
          heightFactor: 0.80,
        );
      } else {
        return Align(
          child: Padding(
          padding: const EdgeInsets.only(left: 50.0),
            child: Image.asset("images/link_start_left.png", width: 260),
          ),
          alignment: Alignment.topCenter,
          heightFactor: 0.80,
        );
      }
    }
    Message prevMessage =  context.read<ServerConnect>().messages[conversation.id]![index - 1];

    if (prevMessage.senderId != tmpUser.id && tmpMessage.senderId == tmpUser.id) {
      return Align(
        child: Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: Image.asset("images/link_left_to_right.png", width: 260),
        ),
        alignment: Alignment.topCenter,
        heightFactor: 0.80,
      );
    }
    if (prevMessage.senderId == tmpUser.id && tmpMessage.senderId != tmpUser.id) {
      return Align(
        child: Padding(
          padding: const EdgeInsets.only(top:10.0, left: 55.0),
          child: Image.asset("images/link_right_to_left.png", width: 260),
        ),
        alignment: Alignment.topCenter,
        heightFactor: 0.80,
      );
    }
    if (prevMessage.senderId != tmpUser.id && tmpMessage.senderId != tmpUser.id) {
      if (index % 2 == 0) {
        return Align(
          child: Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Image.asset("images/link_left1.png", width: 260),
          ),
          alignment: Alignment.topCenter,
          heightFactor: 0.80,
        );
      } else {
        return Align(
          child: Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Image.asset("images/link_left3.png", width: 260),
          ),
          alignment: Alignment.topCenter,
          heightFactor: 0.80,
        );
      }
    }
    if (prevMessage.senderId == tmpUser.id && tmpMessage.senderId == tmpUser.id) {
      if (index % 2 == 0) {
        return Align(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.5,left: 50.0),
            child: Image.asset("images/link_right1.png", width: 260),
          ),
          alignment: Alignment.topCenter,
          heightFactor: 0.80,
        );
      } else {
        return Align(
          child: Padding(
            padding: const EdgeInsets.only(top:8.5, left: 50.0),
            child: Image.asset("images/link_right2.png", width: 260),
          ),
          alignment: Alignment.topCenter,
          heightFactor: 0.80,
        );
      }
    }
    return const Padding(padding: EdgeInsets.all(30));
  }

  Widget getProfilePicture(index) {
    User user = context.read<ServerConnect>().friends.firstWhere((element) => element.id == context.read<ServerConnect>().messages[conversation.id]![index].senderId, orElse: () => User("", "", "", "", ""));
    if (user.urlPicture.isEmpty) {
      return Image.asset("images/default_picture.jpg");
    }
    return Image.network(user.urlPicture, height: 40.0, width: 40.0);
  }

  Widget addMessage(int index) {
    return Align(
      child: context.watch<ServerConnect>().messages[conversation.id]![index].senderId == context.watch<ServerConnect>().user!.id ?
      DisplayMessage(
          index: index,
          message: context.watch<ServerConnect>().messages[conversation.id]![index].content,
          user: context.watch<ServerConnect>().messages[conversation.id]![index].senderId == context.watch<ServerConnect>().user!.id ? true : false
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top:0.0),
            child:  Stack(
              children: [
                Positioned(
                  left: 14.5,
                  top: 12,
                  child: getProfilePicture(index)
                ),
                Image.asset("images/cadre.png", height: 65.0, width: 65.0)
              ]
            ),
          ),
          DisplayMessage(
              index: index,
              message: context.watch<ServerConnect>().messages[conversation.id]![index].content,
              user: context.watch<ServerConnect>().messages[conversation.id]![index].senderId == context.watch<ServerConnect>().user!.id ? true : false
          ),
        ],
      ),
      alignment: Alignment.topCenter,
      heightFactor: 0.70,
    );
  }

  @override
  Widget build(BuildContext context) {
    conversation = ModalRoute.of(context)!.settings.arguments as Conversation;
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.red,
          appBar: AppBar(
            title: Text(conversation.name, style: const TextStyle(color: Colors.black)),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.black),
                onPressed: () async {
                  await auth.FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: _controller,
                itemCount: context.watch<ServerConnect>().messages[conversation.id] != null ? context.read<ServerConnect>().messages[conversation.id]!.length * 2 + 1 : 0,
                itemBuilder: (BuildContext context, int index) {
                  if (index == context.watch<ServerConnect>().messages[conversation.id]!.length * 2) {
                    return const Padding(padding: EdgeInsets.only(bottom: 20));
                  }
                  return index % 2 == 0 ? addLink((index / 2).floor()) : addMessage((index / 2).floor());
                },
              ),
              Image.asset("images/im.png", height: 80)
            ]
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,
                      onTap: () {
                        Timer(
                            const Duration(milliseconds: 575), () => _controller.jumpTo(_controller.position.maxScrollExtent));
                      },
                      onChanged: _onMessage,
                      maxLength: 29,
                      controller: msgController,
                      //autofocus: true,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<ServerConnect>().sendMessage(message, conversation.id);
                      FocusScope.of(context).unfocus();
                      msgController.clear();
                    },
                    child: Image.asset("images/send.png", height: 60)
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}