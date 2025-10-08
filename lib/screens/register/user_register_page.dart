import 'dart:io';
import 'package:adoptapp/screens/home_page.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:adoptapp/strings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adoptapp/entity/usuario.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final UserService _userService = services.get<UserService>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Usuario> usuarios = [];
  XFile? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _profileImage = image;
    });
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      _register();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image:
              AssetImage(Strings.imageCurveRoute), // Ruta de la imagen de fondo
          fit: BoxFit.cover, // Ajusta la imagen para cubrir toda el área
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Hace el fondo del Scaffold transparente para ver el fondo
        appBar: AppBar(
          backgroundColor: Colors
              .transparent, // Hace transparente el AppBar para ver el fondo
          elevation: 0, // Elimina la sombra del AppBar si no la necesitas
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (tu código existente)
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orange,
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo para nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Campo para email
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu email';
                      }
                      // Validación simple de email
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Campo para contraseña
                  TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration('Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Campo para confirmar contraseña
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: _inputDecoration('Confirmar Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Botón de confirmar
                  Center(
                    child: ElevatedButton(
                      onPressed: _validateForm,
                      child: const Text('Registrarse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  void _register() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        //newUsuario(user, _nombreController.text);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Registro exitoso')));
        await user.updateDisplayName(_nameController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: $e')),
      );
    }
  }

  void newUsuario(User user, String nombreUsuario) {
    var usuario = Usuario(user.email!, nombreUsuario, "false");
    _userService.addUser(usuario);
    setState(() {
      usuarios.add(usuario);
    });
  }

//   GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: <String>[
//     'email',
//   ],
// );

//   Future<void> _handleSignOut() async {
//     _googleSignIn.disconnect();
//   }

//   void _pushPage(BuildContext context, Widget page) {
//     Navigator.of(context).push(
//       MaterialPageRoute<void>(builder: (_) => page),
//     );
//   }
}
