import 'package:adoptapp/screens/google_page.dart';
import 'package:adoptapp/screens/register/user_register_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adoptapp/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class LoginPage extends StatefulWidget {
  static final routeName = '/login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPagePageState createState() => _LoginPagePageState();
}

class _LoginPagePageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  String _EmailError = '';
  String _PasswordError = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential userCredential;

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
                      Container(
                          alignment: Alignment.center,
                          height: size.height / 10,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              width: 2.0,
                              color: _isEmailValid ? Colors.orange : Colors.red,
                            ),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              return _EmailError;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: GoogleFonts.inter(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            cursorColor: const Color(0xFF15224F),
                            decoration: InputDecoration(
                              icon:
                                  const Icon(Icons.email, color: Colors.orange),
                              hintText: 'Email',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              border: InputBorder.none,
                              errorMaxLines: 1,
                            ),
                          )),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: size.height / 10,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            width: 2.0,
                            color:
                                _isPasswordValid ? Colors.orange : Colors.red,
                          ),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            return _PasswordError;
                          },
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: const Color(0xFF15224F),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.lock,
                              color: Colors.orange,
                            ),
                            hintText: 'Email',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 12.0,
                              color: Colors.white,
                            ),
                            suffixIcon: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.orange,
                                    ),
                                  ),
                                );
                              },
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (!EmailValidator.validate(
                                _emailController.text)) {
                              setState(() {
                                _isEmailValid = false;
                                _EmailError = 'Email Invalido';
                              });
                            } else {
                              setState(() {
                                _isEmailValid = true;
                                _EmailError = '';
                              });
                            }

                            if (_passwordController.text.isEmpty) {
                              setState(() {
                                _isPasswordValid = false;
                                _PasswordError = 'No puede estar vacio';
                              });
                            } else {
                              setState(() {
                                _isPasswordValid = true;
                                _PasswordError = '';
                              });
                            }

                            if (_isPasswordValid && _isEmailValid) {
                              try {
                                userCredential =
                                    await _auth.signInWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text);
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  setState(() {
                                    _EmailError = 'Usuario no encontrado';
                                    _isEmailValid = false;
                                  });
                                } else if (e.code == 'wrong-password') {
                                  setState(() {
                                    _PasswordError = 'Contraseña incorrecta';
                                    _isPasswordValid = false;
                                  });
                                } else {
                                  // Ocurrió otro error durante el inicio de sesión
                                  print(
                                      'Error al iniciar sesión: ${e.message}');
                                }
                              } catch (e) {
                                // Ocurrió un error inesperado durante el inicio de sesión
                                print('Error al iniciar sesión: $e');
                              } finally {
                                userCredential =
                                    await _auth.signInWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text);
                                User? user = userCredential.user;
                                if (user != null) {
                                  _pushPage(context, const HomePage());
                                } else {}
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0)),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: size.height / 11,
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
                          )),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      signInWithText(),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      signInOneSocialButton(context, size,
                          'assets/logos/apple_logo.svg', 'Sign in with Apple'),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      signInOneSocialButton(
                          context,
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

  Widget signInWithText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
            child: Divider(
          color: Colors.orange,
          thickness: 1.0,
        )),
        const SizedBox(
          width: 16,
        ),
        Text(
          'Or Sign in with',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          width: 16,
        ),
        const Expanded(
            child: Divider(
          color: Colors.orange,
          thickness: 1.0,
        )),
      ],
    );
  }

  //sign up text here
  Widget footerText() {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        children: [
          const TextSpan(
            text: 'Don’t have an account ?',
          ),
          const TextSpan(
            text: ' ',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          TextSpan(
              text: 'Sign up',
              style: const TextStyle(
                color: Color.fromARGB(255, 62, 0, 119),
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _pushPage(context, const RegisterPage())),
        ],
      ),
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

void _pushPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}
