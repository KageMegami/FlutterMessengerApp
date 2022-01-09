import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl2_project/register_page.dart';
import 'package:fl2_project/home_page.dart';
import 'package:fl2_project/user_settings_page.dart';
import 'package:fl2_project/conversation_page.dart';
import 'package:fl2_project/friends_page.dart';
import 'package:fl2_project/search_user_page.dart';
import 'package:fl2_project/server_connect.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider (
      providers : [
        ChangeNotifierProvider(create: (_) => ServerConnect()),
      ],
      child: MaterialApp(
        title: 'Flutter Project',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        initialRoute: '/home',
        routes: {
          '/login': (context) => const MyLoginPage(title: 'Login'),
          '/register': (context) => const MyRegisterPage(title: 'Register'),
          '/home': (context) => const MyHomePage(title: 'Chats'),
          '/user': (context) => const MyUserSettingsPage(title: 'User'),
          '/friends': (context) => const MyFriendsPage(title: 'Friends'),
          '/search': (context) => const MySearchUserPage(title: 'Search'),
          '/conversation': (context) => const MyConversationPage(title: "Conversation"),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  bool errors = false;

  _onSelect(String choice) {
    switch (choice) {
      case "Register":
        Navigator.of(context).pushNamed('/register');
        break;
      case "Home":
        Navigator.of(context).pushReplacementNamed('/home');
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

  forgotPasswordDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        title: const Text("Notice"),
        content: Text("Votre nouveau mot de passe à été envoyer à l'adresse:" + email));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      resizeToAvoidBottomInset: true,
      body: ListView(children: [
        Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
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
                              suffixIcon: Icon(Icons.account_circle),
                            ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veillez entrer votre mot de passe';
                            }
                            return null;
                          },
                          obscureText: true,
                          onChanged: _onUserPass,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: "Mot de passe",
                            suffixIcon: Icon(Icons.lock_open),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: const Text(
                              "Connexion",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.pressed)) {
                                        return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                                      }
                                      return const Color(0xFF1AAAE2); // Use the component's default.
                                    },
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await FirebaseAuth.instance.signInWithEmailAndPassword(
                                    email: email,
                                    password: password
                                );
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  errors = true;
                                } else if (e.code == 'wrong-password') {
                                  errors = true;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                          },
                          child: const Text(
                            "Mot de passe oublié?",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 30.0, right: 20.0),
                                child:
                                const Divider(color: Colors.grey, thickness: 1),
                              ),
                            ),
                            const Text("ou"),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20.0, right: 30.0),
                                child:
                                const Divider(color: Colors.grey, thickness: 1),
                              ),
                            ),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(left: 100, right: 100),
                          child: ElevatedButton(
                            child: const Text("Inscription"),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.lightGreen),
                            onPressed: () {
                              _onSelect("Register");
                            },
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ]),
    );
  }
}
