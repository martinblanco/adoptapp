import 'package:adoptapp/screens/google_page.dart';
import 'package:adoptapp/screens/home_page.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adoptapp/entity/usuario.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final UserService _userService = services.get<UserService>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passswordController = TextEditingController();
  final TextEditingController _passswordConfirmerController =
      TextEditingController();
  List<Usuario> usuarios = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
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
                      emailTextField(size, _emailController),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      passwordTextField(size, _passswordController),
                      passwordTextField(size, _passswordConfirmerController),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      signInButton(size, _emailController, _passswordController,
                          context),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      signInWithText(),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      signInOneSocialButton(
                          context,
                          size,
                          'assets/logos/google_logo.svg',
                          'Sign Up with Google'),
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
          color: const Color(0xFFFF9000),
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
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            icon: const Icon(Icons.email, color: Colors.orange),
            labelText: 'Email',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color.fromARGB(255, 255, 255, 255),
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
          color: const Color(0xFFFF9000),
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
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        maxLines: 1,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            icon: const Icon(
              Icons.lock,
              color: Colors.orange,
            ),
            labelText: 'Password',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            suffixIcon: const Icon(Icons.remove_red_eye, color: Colors.orange),
            border: InputBorder.none),
      ),
    );
  }

  Widget signInButton(Size size, TextEditingController emailController,
      TextEditingController passwordController, BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          _register();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: size.height / 11,
          child: Text(
            'Sign up',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passswordController.text,
    );
    User? user = userCredential.user;
    user?.updateDisplayName(_nombreController.text);
    if (user != null) {
      setState(() {});
      newUsuario(user, _nombreController.text);
    } else {}
  }

  void newUsuario(User user, String nombreUsuario) {
    var usuario = Usuario(user.email!, nombreUsuario, "false");
    _userService.addUser(usuario);
    setState(() {
      usuarios.add(usuario);
    });
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
          'Or Sing Up with',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color.fromARGB(255, 255, 255, 255),
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
}

signInOneSocialButton(
    BuildContext context, Size size, String iconPath, String text) {
  return ElevatedButton(
      onPressed: () => _pushPage(context, const SignInDemo()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      ),
      child: Container(
        height: size.height / 12,
        alignment: Alignment.center,
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ],
        ),
      ));
}

void signInWithEmail(TextEditingController _emailController,
    TextEditingController _passwordController, BuildContext context) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserCredential userCredential;
  try {
    userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
  } catch (e) {
    null;
  } finally {
    userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    User? user = userCredential.user;
    if (user != null) {
      _pushPage(context, const HomePage());
    } else {}
  }
}

void _pushPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}
