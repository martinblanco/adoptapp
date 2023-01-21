import 'package:adoptapp/entity/usuario.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adoptapp/database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  final String title = 'Registration';

  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<Usuario> usuarios = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _passswordController = TextEditingController();
  bool _success = false;
  late String _userEmail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de Usuario'),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Ingresa un nombre de usuario';
                }
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Ingresa un Mail';
                }
              },
            ),
            TextFormField(
              controller: _passswordController,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Ingresa una contraseña';
                }
              },
            ),
            TextButton(
                child: Text('Register'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _register();
                }),
            Container(
              alignment: Alignment.center,
              child: Text(_success == null
                  ? ''
                  : (_success
                      ? 'Successfully registered' + _userEmail
                      : 'Registration failed')),
            )
          ],
        ),
      ),
    );
  }

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
      setState(() {
        _success = true;
        _userEmail = user.email!;
      });
      newUsuario(user, _nombreController.text);
    } else {
      _success = false;
    }
  }

  void newUsuario(User user, String nombreUsuario) {
    // ignore: unnecessary_new
    var usuario = new Usuario(user.email!, nombreUsuario, "false");
    usuario.setId(saveUsuario(usuario));
    this.setState(() {
      usuarios.add(usuario);
    });
  }
}
