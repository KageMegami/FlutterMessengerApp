import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:fl2_project/server_connect.dart';
import 'model/user.dart';

class MyUserSettingsPage extends StatefulWidget {
  const MyUserSettingsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyUserSettingsPageState createState() => _MyUserSettingsPageState();
}

class _MyUserSettingsPageState extends State<MyUserSettingsPage> {
  String firstName = "";
  String lastName = "";
  String? urlPicture;
  File? _imageFile;
  bool _newUser = false;

  @override
  void initState() {
    super.initState();
    User? user = context.read<ServerConnect>().user;
    if (user == null) {
      return;
    }
    firstName = user.firstName;
    lastName = user.lastName;
    urlPicture = user.urlPicture;
  }

  _onUserFirst(String _first) {
    firstName = _first;
  }

  _onUserLast(String _last) {
    lastName = _last;
  }

  void _openGallery(BuildContext context) async{
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future _cropImage(File pickedImage) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedImage.path,
        maxWidth: 1080,
        maxHeight: 1080,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0)
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        _imageFile = croppedFile;
      });
    }
  }

  Future _updateUser(BuildContext context) async {
    String? path = await _uploadImageToFirebase(context);
    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your profile is not complete'),
      ));
      return;
    }
    bool result = await context.read<ServerConnect>().updateUser(firstName, lastName, path);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result ? 'Profile update successfully': 'An error occur please try again later'),
    ));
  }

  Future _registerUser(BuildContext context) async {
    String? path = await _uploadImageToFirebase(context);
    if (path == null || firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your profile is not complete'),
      ));
      return;
    }
    bool result = await context.read<ServerConnect>().registerUser(firstName, lastName, path);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result ? 'Profile update successfully': 'An error occur please try again later'),
    ));

  }


  Future<String?> _uploadImageToFirebase(BuildContext context) async {
    if (_imageFile == null) {
      return null;
    }
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('userProfilePicture').child(auth.FirebaseAuth.instance.currentUser!.uid);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile!);
    await uploadTask.whenComplete(() {
      return;
    });
    return firebaseStorageRef.fullPath;
  }

  _getPictureToDisplay() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (urlPicture != null) {
      return NetworkImage(urlPicture!);
    } else {
      return const AssetImage("images/defaultProfilePicture.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    _newUser = ModalRoute.of(context)!.settings.arguments as bool;

    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text(widget.title),
        actions: const <Widget>[],
      ),
      body: ListView(children: [
        Column(
          children: <Widget>[
             Padding(
              padding: const EdgeInsets.only(top: 100),
              child: TextButton(
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: _getPictureToDisplay(),
                ), onPressed: () => _openGallery(context)
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 50),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 230),
              child: Text("Last Name"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                onChanged: _onUserLast,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(),
                  labelText: lastName,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 280),
              child: Text("Fist Name"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                onChanged: _onUserFirst,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(),
                  labelText: firstName,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.black),
                child: const Text("Update", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  _newUser ? _registerUser(context) : _updateUser(context);
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
