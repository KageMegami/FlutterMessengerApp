import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl2_project/server_connect.dart';

class MySearchUserPage extends StatefulWidget {
  const MySearchUserPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MySearchUserPageState createState() => _MySearchUserPageState();
}

class _MySearchUserPageState extends State<MySearchUserPage> {
  String query = "";

  _onSearch(String _query) {
    query = _query;
    context.read<ServerConnect>().searchUser(query);
  }

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
              Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                  child: Align(alignment: Alignment.centerLeft,
                      child: TextField(
                        onChanged: _onSearch,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                  )
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: context.watch<ServerConnect>().queried.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                          children: [
                            Positioned(
                                left: 14.5,
                                top: 12,
                                child: Image.network(context.watch<ServerConnect>().queried[index].urlPicture, height: 63.0, width: 63.0)),
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
                              context.read<ServerConnect>().queried[index].firstName + " " + context.read<ServerConnect>().queried[index].lastName,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          context.read<ServerConnect>().sendFriendRequest(context.read<ServerConnect>().queried[index].id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Friend request sent'),
                          ));
                        },
                        child: CircleAvatar(
                          radius: 20,
                          child: Image.asset("images/cross.png", height: 20.0, width: 20.0),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        )
    );
  }
}