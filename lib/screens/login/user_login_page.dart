import 'package:adoptapp/screens/register/user_register_page.dart';
import 'package:adoptapp/strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:adoptapp/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>['email'],
);

class LoginPage extends StatefulWidget {
  static const routeName = Strings.loginRoute;
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPagePageState createState() => _LoginPagePageState();
}

class _LoginPagePageState extends State<LoginPage> {
  GoogleSignInAccount? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _forLoginKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
          key: _forLoginKey,
          child: Stack(
            children: [
              _buildBackground(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      logo(size.height / 8, size.height / 8),
                      separator(size.height, 3),
                      _buildEmailField(),
                      separator(size.height, 1),
                      _buildPasswordField(),
                      separator(size.height, 2),
                      _buildSignInButton(size.height),
                      separator(size.height, 1),
                      textDivider(),
                      separator(size.height, 2),
                      signInGoogle(
                        context,
                        size,
                        Strings.googleLogoRoute,
                        Strings.googleSingIn,
                      ),
                      separator(size.height, 3),
                      Center(child: footerText(context)),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildSignInButton(double height) {
    return ElevatedButton(
      onPressed: () async {
        await _signIn(false);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
      child: const Text(Strings.loginButton),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage(Strings.imageCurveRoute),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.orange, width: 2.0),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration("Email").copyWith(
        errorText: _isEmailValid() ? null : 'Email inválido',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) => _isEmailValid(value) ? null : 'Email inválido',
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePasswordNotifier,
      builder: (context, obscure, child) {
        return TextFormField(
          controller: _passwordController,
          obscureText: obscure,
          decoration: _inputDecoration("Contraseña").copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.orange,
              ),
              onPressed: () {
                _obscurePasswordNotifier.value =
                    !_obscurePasswordNotifier.value;
              },
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Contraseña inválida' : null,
        );
      },
    );
  }

  Widget separator(double height, int mul) {
    return SizedBox(
      height: height * 0.02 * mul,
    );
  }

  bool _isEmailValid([String? email]) {
    const emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    return RegExp(emailPattern).hasMatch(email ?? _emailController.text);
  }

  Future<void> _signIn(bool isGoogle) async {
    try {
      User? user;
      UserCredential userCredential;
      if (isGoogle) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      user = userCredential.user;
      if (user != null) {
        _pushPage(context, const HomePage());
      }
    } on FirebaseAuthException catch (e) {
      logger.e(e.message ?? 'Error desconocido');
    } catch (e) {
      logger.e('Error: $e');
    }
  }

  Widget logo(double height_, double width_) {
    return SvgPicture.asset(
      Strings.appLogoRoute,
      height: height_,
      width: width_,
    );
  }

  Widget textDivider() {
    const divider = Expanded(
      child: Divider(
        color: Colors.orange,
        thickness: 1.0,
      ),
    );

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        divider,
        SizedBox(width: 16),
        Text(
          Strings.orSignItWith,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.white, // Color blanco para el texto
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(width: 16),
        divider,
      ],
    );
  }

  Widget footerText(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.white,
        ),
        children: [
          const TextSpan(
            text: Strings.dontAccount,
          ),
          TextSpan(
            text: Strings.signUp,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _pushPage(context, const RegisterPage()),
          ),
        ],
      ),
    );
  }

  Widget signInGoogle(
      BuildContext context, Size size, String iconPath, String text) {
    return ElevatedButton(
      onPressed: () => _signIn(true),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        padding: EdgeInsets.symmetric(vertical: size.height / 36),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account!;
      });
      if (_currentUser != null) {
        _pushPage(context, const HomePage());
      }
    });
  }
}
