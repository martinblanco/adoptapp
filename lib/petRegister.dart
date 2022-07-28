// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'database.dart';
import 'mascota.dart';

class RegisterPet extends StatefulWidget {
  final String title = 'Registration';

  State<StatefulWidget> createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  List<Mascota> mascotas = [];
  void newMascota(String text) {
    var mascota = new Mascota(text, text, text, text, text, text);
    mascota.setId(saveMascota(mascota));
    this.setState(() {
      mascotas.add(mascota);
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passswordController = TextEditingController();
  late bool _success;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildTextField('Nomre'),
            buildTextField('Edad'),
            buildTextField('Tamaño'),
            buildTextField('Descripcion'),
            buildBotton('Agregar Mascota'),
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

  Widget buildTextField(String label) => TextFormField(
        controller: _emailController,
        maxLength: 10,
        decoration: InputDecoration(labelText: label),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Este campo no puede estar vacio';
          }
        },
      );

  Widget buildBotton(String label) => TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        primary: Colors.white,
        backgroundColor: Colors.orangeAccent,
        textStyle: const TextStyle(fontSize: 10),
        shape: StadiumBorder(),
      ),
      child: Text(label),
      onPressed: () {
        newMascota(_emailController.text);
      });

  void dispose() {
    _emailController.dispose();
    _passswordController.dispose();
    super.dispose();
  }

  void _register() async {
    //   final UserCredential userCredential =
    //       await _auth.createUserWithEmailAndPassword(
    //     email: _emailController.text,
    //     password: _passswordController.text,
    //   );
    //   User? user = userCredential.user;
    //   if (user != null) {
    //     setState(() {
    //       _success = true;
    //       _userEmail = user.email!;
    //     });
    //   } else {
    //     _success = false;
    //   }
  }
}
