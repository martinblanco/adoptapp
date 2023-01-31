import 'package:flutter/material.dart';
import 'package:adoptapp/googlePage.dart';
import 'package:adoptapp/userRegisterPage.dart';
import 'package:adoptapp/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adoptapp/entity/mascota.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class LoginPage extends StatefulWidget {
  final String title;

  const LoginPage({Key? key, required this.title}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<Mascota> mascotas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage('assets/images/curved.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 400, top: 100),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage('assets/images/Logo.png'),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            Card(
              color: Colors.grey[100],
              margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 250.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLines: 1,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          icon: Icon(Icons.email, color: Colors.blue)),
                      onFieldSubmitted: (value) {
                        //FocusScope.of(context).requestFocus(_phoneFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Type your name';
                        }
                      },
                    ),
                    Container(
                      child: TextFormField(
                        maxLines: 1,
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            icon: Icon(
                              Icons.vpn_key,
                              color: Colors.blue,
                            ),
                            suffixIcon:
                                Icon(Icons.remove_red_eye, color: Colors.blue)),
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Type your password';
                          }
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 30.0)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // background
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          padding: const EdgeInsets.all(16.0) // foreground
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () {
                        signInWithEmail();
                      },
                    ),
                    const Divider(),
                    const Text(
                      'OR',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    const Divider(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // background
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          padding: const EdgeInsets.all(16.0) // foreground
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text(
                            'Google Sign In',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () => _pushPage(context, SignInDemo()),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                          right: 32,
                        ),
                        child: InkWell(
                          onTap: () => _pushPage(context, RegisterPage()),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signInWithEmail() async {
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
}

void _pushPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}
