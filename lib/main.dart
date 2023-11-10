import 'dart:async';
import 'package:adoptapp/page/home_page.dart';
import 'package:adoptapp/user_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AdoptApp());
}

class AdoptApp extends StatefulWidget {
  const AdoptApp({Key? key}) : super(key: key);

  @override
  _AdoptAppState createState() => _AdoptAppState();
}

class _AdoptAppState extends State<AdoptApp> {
  late StreamSubscription<User?> user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      user == null ? print("signed out") : print("signed in");
    });
  }

  @override
  void dispose() {
    user.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: FirebaseAuth.instance.currentUser == null ? "sing" : "home",
      routes: {
        "sing": (context) => SignInOne(),
        "home": (context) => HomePage(),
      },
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          textTheme:
              TextTheme(bodyText2: GoogleFonts.quicksand(fontSize: 14.0))),
      home: SignInOne(),
    );
  }
}
