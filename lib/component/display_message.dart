import 'package:flutter/material.dart';

class DisplayMessage extends StatelessWidget {
  const DisplayMessage({Key? key, required this.index, required this.message, required this.user}) : super(key: key);

  final int index;
  final String message;
  final bool user;


  String getCorrectBubble() {
    if (message.length < 8) {
      return user ? "images/small_right.png" : "images/small_left.png";
    } else if (message.length >= 8 && message.length < 30) {
      return user ? "images/medium_right.png" : "images/medium_left.png";
    } else {
      return user ? "images/long_right.png" : "images/long_left.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: user == true ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        children: <Widget> [
          // user ? getLinkRight() : getLinkLeft(),
          Padding(
            padding: const EdgeInsets.only(top:0.0),
            child: Image.asset(getCorrectBubble()),
          ),
          Positioned(
            top: 15,
            right: user == true ? 45 : null,
            left: user == true ? null : 45,
            child: Text(
              message,
              style: TextStyle(
                color: user == true ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}