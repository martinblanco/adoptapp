import 'dart:async';
import 'package:adoptapp/screens/home_page.dart';
import 'package:adoptapp/screens/login/user_login_page.dart';
import 'package:adoptapp/screens/register/user_register_page.dart';
import 'package:adoptapp/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initServices();
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? LoginPage.routeName
          : HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => HomePage(),
        LoginPage.routeName: (context) => LoginPage(),
        RegisterPage.routeName: (context) => RegisterPage(),
      },
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          textTheme:
              TextTheme(bodyText2: GoogleFonts.quicksand(fontSize: 14.0))),
    );
  }

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
}
