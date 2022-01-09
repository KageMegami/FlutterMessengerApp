import 'dart:async';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl2_project/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'model/conversation.dart';
import 'model/message.dart';
import 'model/friend_request.dart';

class ServerConnect with ChangeNotifier {
  User? user;
  List<Conversation> conversations = [];
  Map<String, List<Message>> messages = {};
  List<User> friends = [];
  List<User> queried = [];
  List<FriendRequest> friendRequests = [];
  String startUrl = "http://151.80.157.66:3000";
  String token = "";

  void setToken(String _token) {
    token = _token;
  }


  clear() {
    user = null;
    conversations = [];
    messages = {};
  }

  void addRecievedMessage(Message newMessage, String conversationId) {
    messages.update(conversationId, (value) { value.add(newMessage); return value;});
    notifyListeners();
  }

  Future<User?> getUser() async {
    final url = Uri.parse("$startUrl/users");
    var completer = Completer<User?>();

    get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }).then((response) async {
      final Map parsed = json.decode(response.body);
      if (!parsed.containsKey("id")) {
        completer.complete(null);
        return;
      }
      var urlPicture = await FirebaseStorage.instance.ref().child(parsed["url_picture"]).getDownloadURL();

      user = User(parsed["id"], parsed["firstName"], parsed["lastName"], urlPicture, parsed["url_picture"]);
      notifyListeners();
      completer.complete(user);
    }).catchError((onError) {
      completer.completeError(onError);

    });
    return completer.future;
  }

  Future<bool> registerUser(String firstName, String lastName, String urlPicture) async {

    final url = Uri.parse("$startUrl/users");
    Map<String, String> body = {
      "firstName": firstName,
      "lastName": lastName,
      "url_picture": urlPicture,
    };
    final completer = Completer<bool>();
    post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: body).then((response) async {
      var parsed = json.decode(response.body);
      if (!parsed.containsKey("id")) {
        completer.complete(false);
        return;
      }

      var urlPicture = await FirebaseStorage.instance.ref().child(parsed["url_picture"]).getDownloadURL();

      user = User(parsed["id"], parsed["firstName"], parsed["lastName"], urlPicture, parsed["url_picture"]);
      notifyListeners();

      completer.complete(true);
    }).catchError((onError) {
      completer.complete(false);
    });
    return completer.future;
  }

    Future<bool> updateUser(String firstName, String lastName, String? urlPicture) async {
    final url = Uri.parse("$startUrl/users/update");
    Map<String, String> body = {
      "firstName": firstName,
      "lastName": lastName,
      "url_picture": urlPicture ?? user!.storagePath,
    };
    final completer = Completer<bool>();
    post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: body).then((response) async {
      var parsed = json.decode(response.body);
      if (!parsed.containsKey("id")) {
        completer.complete(false);
        return;
      }

      var urlPicture = await FirebaseStorage.instance.ref().child(parsed["url_picture"]).getDownloadURL();

      user = User(parsed["id"], parsed["firstName"], parsed["lastName"], urlPicture, parsed["url_picture"]);
      notifyListeners();

      completer.complete(true);
    }).catchError((onError) {
      completer.complete(false);
    });
    return completer.future;
  }

  Future<bool> updateToken(String fcmToken) async {
    final url = Uri.parse("$startUrl/users/token");
    Map<String, String> body = {
      "token": fcmToken,
    };
    final completer = Completer<bool>();
    post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: body).then((response) async {
      var parsed = json.decode(response.body);
      if (!parsed.containsKey("id")) {
        completer.complete(false);
        return;
      }
      completer.complete(true);
    }).catchError((onError) {
      completer.complete(false);
    });
    return completer.future;
  }

  Future getUserConversations() async{
    final url = Uri.parse("$startUrl/users/conversations");
    var completer = Completer();

    get(url, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
    }).then((response) async{
      final List parsedList = json.decode(response.body);

      conversations = await Future.wait(parsedList.map((val) async {
        var urlPicture = val["url_picture"] != null ? await FirebaseStorage.instance.ref().child(val["url_picture"]).getDownloadURL() : null;
        return Conversation(val["id"], val["name"], urlPicture);
      }));
      for (var conv in conversations) {
        getConversationMessages(conv.id);
      }
      notifyListeners();
      completer.complete(parsedList);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future getConversationUsers(String idConversation) {
    final url = Uri.parse("$startUrl/users/conversations/$idConversation/users");
    var completer = Completer();
    final Map<String, String> header = {
      "Authorization": "bearer $token",
    };
    get(url, headers: header).then((response) {
      var data = jsonDecode(response.body);
      completer.complete(data);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future getConversationMessages(String idConversation) {
    final url = Uri.parse("$startUrl/conversations/$idConversation/messages");
    var completer = Completer();
    get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }).then((response) {
      final List parsedList = json.decode(response.body);
      List<Message> conversationMessage = parsedList.map((val) => Message(val["id"], val["sender_id"], val["content"])).toList();
      messages.update(idConversation, (old) => conversationMessage, ifAbsent: () => conversationMessage);
      notifyListeners();
      completer.complete(parsedList);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future getUserFriends() {
    final url = Uri.parse("$startUrl/users/friends");
    var completer = Completer();
    final Map<String, String> header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    get(url, headers: header).then((response) async {
      final List parsedList = json.decode(response.body);
      friends = await Future.wait(parsedList.map((val) async {
        var urlPicture = await FirebaseStorage.instance.ref().child(val["url_picture"]).getDownloadURL();
        return User(val["id"], val["firstName"], val["lastName"], urlPicture, val["url_picture"]);
      }));
      notifyListeners();
      completer.complete(parsedList);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future getFriendRequest() {
    final url = Uri.parse("$startUrl/users/friends/requests");
    var completer = Completer();
    final Map<String, String> header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    get(url, headers: header).then((response) async {
      final List parsedList = json.decode(response.body);
      friendRequests = await Future.wait(parsedList.map((val) async {
        var urlPicture = await FirebaseStorage.instance.ref().child(val["user"]["url_picture"]).getDownloadURL();
        return FriendRequest(val["id"], User(val["user"]["id"], val["user"]["firstName"], val["user"]["lastName"], urlPicture, val["user"]["url_picture"]));
      }));
      notifyListeners();
      completer.complete(parsedList);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future sendMessage(String content, String idConversation) {
    final url = Uri.parse("$startUrl/messages");
    Map<String, String> body = {
      "content": content,
      "conversation_id": idConversation,
    };
    var completer = Completer();
    post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: body).then((response) {
      var parsed = json.decode(response.body);
      if (!parsed.containsKey("id")) {
        return;
      }
      completer.complete(parsed);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future sendFriendRequest(String idUser) {
    final url = Uri.parse("$startUrl/users/friends/requests");
    final Map<String, String> header = {
      'Authorization': 'Bearer $token'
    };
    Map<String, String> body = {
      "userId": idUser,
    };
    var completer = Completer();
    post(url, headers: header, body: body).then((response) {
      completer.complete(true);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future answerFriendRequest(String idRequest, String answer) {
    final url = Uri.parse("$startUrl/users/friends/requests/answer");
    final Map<String, String> header = {
      'Authorization': 'Bearer $token'
    };
    Map<String, String> body = {
      "requestId": idRequest,
      "response": answer,
    };
    var completer = Completer();
    post(url, headers: header, body: body).then((response) {
      notifyListeners();
      completer.complete(true);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }

  Future searchUser(String query) {
    final url = Uri.parse("$startUrl/users/search");
    final Map<String, String> header = {
      'Authorization': 'Bearer $token'
    };
    Map<String, String> body = {
      "query": query,
    };
    var completer = Completer();
    post(url, headers: header, body: body).then((response) async{
      final List parsedList = json.decode(response.body);
      queried = await Future.wait(parsedList.map((val) async {
        var urlPicture = await FirebaseStorage.instance.ref().child(val["url_picture"]).getDownloadURL();
        return User(val["id"], val["firstName"], val["lastName"], urlPicture, val["url_picture"]);
      }));
      //queried = parsedList.map((val) => User(val["id"], val["firstName"], val["lastName"], val["url_picture"], "")).toList();
      notifyListeners();
      completer.complete(parsedList);
    }).catchError((onError) {
      completer.completeError(onError);
    });
    return completer.future;
  }
}