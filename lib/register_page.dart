import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyRegisterPageState createState() => _MyRegisterPageState();
}

class _MyRegisterPageState extends State<MyRegisterPage> {
  String email = "";
  String password = "";
  bool errors = false;

  _onSelect(String choice) {
    switch (choice) {
      case "Home":
        Navigator.of(context).pop('/');
        break;
      default:
        Navigator.of(context).pushNamed('/');
        break;
    }
  }

  _onUserMail(String _email) {
    email = _email;
  }

  _onUserPass(String _password) {
    password = _password;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            iconTheme: const IconThemeData(
              color: Colors.black, //change your color here
            ),
            toolbarHeight: 50,
          ),
          body: ListView(
            children: [
              Column(
                children: <Widget> [
                  Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                                child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer votre email';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onChanged: _onUserMail,
                                    decoration: const InputDecoration(
                                      labelText: "Addresse mail",
                                    )
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                                child: TextFormField(
                                  validator: (value) {
                                    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,100}$';
                                    RegExp regExp = RegExp(pattern);
                                    if (value == null || value.isEmpty) {
                                      return 'Veillez entrer un mot de passe';
                                    } else if (!regExp.hasMatch(value)) {
                                      return 'Mot de passe doit contenir une minuscile, une majuscule,\nun chiffre et un caractère spécial et faire au moins 8 caractères';
                                    }
                                    return null;
                                  },
                                  obscureText: true,
                                  onChanged: _onUserPass,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: "Mot de passe",
                                  ),
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                                child: TextFormField(
                                  validator: (value) {
                                    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,100}$';
                                    RegExp(pattern);
                                    if (value == null || value.isEmpty) {
                                      return 'Veillez entrer le mot de passe à nouveau';
                                    } else if (!(value == password)) {
                                      return 'Le mot de passe est différent';
                                    } else {
                                      return null;
                                    }
                                  },
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    labelText: "Confimation de mot de passe",
                                  ),
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                                child: Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        child: const Text("Inscription"),
                                        onPressed: () async {
                                          try {
                                            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                                email: email,
                                                password: password
                                            );
                                          } on FirebaseAuthException catch (e) {
                                            if (e.code == 'weak-password') {
                                              errors = true;
                                            } else if (e.code == 'email-already-in-use') {
                                              errors = true;
                                            }
                                          }
                                          if (errors == false) {
                                            _onSelect("Home");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.lightGreen)),
                                  ),
                                )
                            )
                          ]
                      )
                  )
                ],
              ),
            ],
          ),
        )
    );
  }
}