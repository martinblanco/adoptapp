import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adoptapp/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class SignInOne extends StatefulWidget {
  const SignInOne({Key? key}) : super(key: key);

  @override
  _SignInOnePageState createState() => _SignInOnePageState();
}

class _SignInOnePageState extends State<SignInOne> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage('assets/images/curved.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      logo(size.height / 8, size.height / 8),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      emailTextField(size, _emailController),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      passwordTextField(size, _passwordController),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      signInButton(
                          size, _emailController, _passwordController, context),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      signInWithText(),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      SignInOneSocialButton(size, 'assets/logos/apple_logo.svg',
                          'Sign in with Apple'),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      SignInOneSocialButton(
                          size,
                          'assets/logos/google_logo.svg',
                          'Sign in with Google'),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Center(
                        child: footerText(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget logo(double height_, double width_) {
    return SvgPicture.asset(
      'assets/logos/logo.svg',
      height: height_,
      width: width_,
    );
  }

  Widget emailTextField(Size size, TextEditingController _emailController) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextFormField(
        maxLines: 1,
        controller: _emailController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (value) {
          //FocusScope.of(context).requestFocus(_phoneFocusNode);
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Type your Email';
          }
        },
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            icon: Icon(Icons.email, color: Colors.blue),
            labelText: 'Email',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            border: InputBorder.none),
      ),
    );
  }

  Widget passwordTextField(
      Size size, TextEditingController _passwordController) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Type your Password';
          }
        },
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            icon: Icon(
              Icons.lock,
              color: Colors.blue,
            ),
            labelText: 'Password',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            suffixIcon: Icon(Icons.remove_red_eye, color: Colors.blue),
            border: InputBorder.none),
      ),
    );
  }

  Widget signInButton(Size size, TextEditingController emailController,
      TextEditingController passwordController, BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          signInWithEmail(emailController, passwordController, context);
        },
        child: Container(
          alignment: Alignment.center,
          height: size.height / 11,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: const Color(0xFF21899C),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C2E84).withOpacity(0.2),
                offset: const Offset(0, 15.0),
                blurRadius: 60.0,
              ),
            ],
          ),
          child: Text(
            'Sign in',
            style: GoogleFonts.inter(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget signInWithText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: Divider()),
        const SizedBox(
          width: 16,
        ),
        Text(
          'Or Sign in with',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF969AA8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          width: 16,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  //sign up text here
  Widget footerText() {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFF3B4C68),
        ),
        children: const [
          TextSpan(
            text: 'Don’t have an account ?',
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: Color(0xFF21899C),
            ),
          ),
          TextSpan(
            text: 'Sign up',
            style: TextStyle(
              color: Color(0xFF21899C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

SignInOneSocialButton(Size size, String iconPath, String text) {
  return Container(
    height: size.height / 12,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40.0),
      border: Border.all(
        width: 1.0,
        color: const Color(0xFF134140),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: SvgPicture.asset(iconPath),
        ),
        Expanded(
          flex: 2,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16.0,
              color: const Color(0xFF134140),
            ),
          ),
        ),
      ],
    ),
  );
}

void signInWithEmail(TextEditingController _emailController,
    TextEditingController _passwordController, BuildContext context) async {
  // marked async
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserCredential userCredential;
  try {
    userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    User? user = userCredential.user;
  } catch (e) {
    print(e.toString());
  } finally {
    userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    User? user = userCredential.user;
    if (user != null) {
      // sign in successful!
      _pushPage(context, const PetGrid());
    } else {
      // sign in unsuccessful
      print('sign in Not');
      // ex: prompt the user to try again
    }
  }
}

void _pushPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}
