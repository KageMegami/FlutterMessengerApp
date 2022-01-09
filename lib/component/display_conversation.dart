import 'package:fl2_project/model/conversation.dart';
import 'package:flutter/material.dart';

class DisplayConversation extends StatelessWidget {
  const DisplayConversation({Key? key, required this.conversation}) : super(key: key);

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        Image.asset("images/bubble_list.png", width: 225),
        Positioned(
          top: 25,
          left: 45,
          child: Text(
            conversation.name,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}