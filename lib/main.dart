import 'dart:async';
import 'package:adoptapp/providers/mascotas_provider.dart';
import 'package:adoptapp/screens/home_page.dart';
import 'package:adoptapp/screens/login/user_login_page.dart';
import 'package:adoptapp/screens/mascotas/mascota_deep_link_page.dart';
import 'package:adoptapp/screens/register/user_register_page.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final GoRouter router = _buildRouter(isLoggedIn);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => MascotasNotifier()..loadMascotas()),
      ],
      child: MaterialApp.router(
        title: Strings.appTitle,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: _buildThemeData(),
      ),
    );
  }

  GoRouter _buildRouter(bool isLoggedIn) {
    return GoRouter(
      initialLocation: isLoggedIn ? HomePage.routeName : LoginPage.routeName,
      routes: [
        GoRoute(
          path: LoginPage.routeName,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RegisterPage.routeName,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: HomePage.routeName,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/mascota/:id',
          builder: (context, state) =>
              MascotaDeepLinkPage(petId: state.pathParameters['id'] ?? ''),
        ),
      ],
      errorBuilder: (context, state) => const LoginPage(),
    );
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
