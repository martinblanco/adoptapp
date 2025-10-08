import 'dart:async';
import 'package:adoptapp/screens/home_page.dart';
import 'package:adoptapp/screens/login/user_login_page.dart';
import 'package:adoptapp/screens/register/user_register_page.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const App());
}

Future<void> _initializeApp() async {
  await Firebase.initializeApp();
  initServices();
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? LoginPage.routeName
          : HomePage.routeName,
      routes: _buildRoutes(),
      theme: _buildThemeData(),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      HomePage.routeName: (context) => const HomePage(),
      LoginPage.routeName: (context) => const LoginPage(),
      RegisterPage.routeName: (context) => const RegisterPage(),
    };
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: Strings.fontFamily,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
