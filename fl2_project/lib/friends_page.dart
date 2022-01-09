import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl2_project/server_connect.dart';

class MyFriendsPage extends StatefulWidget {
  const MyFriendsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyFriendsPageState createState() => _MyFriendsPageState();
}

class _MyFriendsPageState extends State<MyFriendsPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.red,
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(color: Colors.black)),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.black),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 0.0),
                  child: Align(alignment: Alignment.centerLeft,
                      child: Text("Friend Requests", style: TextStyle(color: Colors.black),)
                  )
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: context.watch<ServerConnect>().friendRequests.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                          children: [
                            Positioned(
                                left: 14.5,
                                top: 12,
                                child: Image.network(context.watch<ServerConnect>().friendRequests[index].user.urlPicture, height: 63.0, width: 63.0)),
                            Image.asset("images/cadre.png", height: 90.0, width: 90.0)
                          ]
                      ),
                      Stack(
                        children: <Widget> [
                          Image.asset("images/bubble_list.png", width: 225),
                          Positioned(
                            top: 25,
                            left: 45,
                            child: Text(
                              context.watch()<ServerConnect>().friendRequests[index].user.firstName + " " + context.watch()<ServerConnect>().friendRequests[index].user.lastName,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              context.read<ServerConnect>().answerFriendRequest(context.read<ServerConnect>().friendRequests[index].id, "true");
                              context.read<ServerConnect>().getUserConversations();
                              context.read<ServerConnect>().getUserFriends();
                              context.read<ServerConnect>().getFriendRequest();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Friend request accepted'),
                              ));
                            },
                            child: CircleAvatar(
                              radius: 20,
                              child: Image.asset("images/accept.png", height: 20.0, width: 20.0),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.fromLTRB(60.0, 10.0, 0.0, 0.0)),
                          InkWell(
                            onTap: () {
                              context.read<ServerConnect>().answerFriendRequest(context.read<ServerConnect>().friendRequests[index].id, "false");
                              context.read<ServerConnect>().getUserConversations();
                              context.read<ServerConnect>().getUserFriends();
                              context.read<ServerConnect>().getFriendRequest();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Friend request declined'),
                              ));
                            },
                            child: CircleAvatar(
                              radius: 20,
                              child: Image.asset("images/refuse.png", height: 20.0, width: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 20.0),
                child: const Divider(color: Colors.black, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                    child: Align(alignment: Alignment.centerLeft,
                        child: Text("Friends", style: TextStyle(color: Colors.black),)
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed('/search');
                      },
                      child: CircleAvatar(
                        radius: 20,
                        child: Image.asset("images/cross.png", height: 20.0, width: 20.0),
                      ),
                    ),
                  )
                ]
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: context.watch<ServerConnect>().friends.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                            children: [
                              Positioned(
                                  left: 14.5,
                                  top: 12,
                                  child: Image.network(context.watch<ServerConnect>().friends[index].urlPicture, height: 63.0, width: 63.0)),
                              Image.asset("images/cadre.png", height: 90.0, width: 90.0)
                            ]
                        ),
                        Stack(
                          children: <Widget> [
                            Image.asset("images/bubble_list.png", width: 225),
                            Positioned(
                              top: 25,
                              left: 45,
                              child: Text(
                                context.read<ServerConnect>().friends[index].firstName + " " + context.read<ServerConnect>().friends[index].lastName,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop("/home"), child: Image.asset("images/chats.png", height: 90)),
                    Image.asset("images/friends.png", height: 60),
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