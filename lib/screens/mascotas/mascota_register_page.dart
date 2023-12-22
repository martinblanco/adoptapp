import 'dart:io';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/widgets/selector_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPet extends StatefulWidget {
  final String title = 'Registration';
  late SelectorCard animal;
  late SelectorCard sexo;
  late SelectorCard size;

  RegisterPet({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final MascotasService _mascotaService = services.get<MascotasService>();
  List<Mascota> mascotas = [];
  late File imagen;
  late String url;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passswordController = TextEditingController();
  late final bool _success = false;
  late String _userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Form(
        key: _formKey,
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: getImage,
                child: const Text("FOTO"),
              ),
              buildTextField('Nombre'),
              buildTextField('Descripcion'),
              widget.animal = SelectorCard(
                  title: "Animal",
                  texts: const ["Perro", "Gato"],
                  icons: const [FontAwesomeIcons.dog, FontAwesomeIcons.cat]),
              widget.sexo = SelectorCard(
                  title: "Sexo",
                  texts: const ["Hembra", "Macho"],
                  icons: const [FontAwesomeIcons.venus, FontAwesomeIcons.mars]),
              widget.size = SelectorCard(title: "Tamaño", texts: const [
                "Chico",
                "Mediano",
                "Grande"
              ], icons: const [
                FontAwesomeIcons.s,
                FontAwesomeIcons.m,
                FontAwesomeIcons.l
              ]),
              buildBotton('Agregar Mascota'),
              Container(
                alignment: Alignment.center,
                child: Text(_success == false
                    ? ''
                    : (_success
                        ? 'Successfully registered' + _userEmail
                        : 'Registration failed')),
              )
            ],
          )
        ]),
      ),
    );
  }

  Widget buildTextField(String label) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        focusNode: FocusNode(),
        controller: _emailController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: label),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Este campo no puede estar vacio';
          }
          return null;
        },
      ));

  Widget buildBotton(String label) => TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.orangeAccent,
        textStyle: const TextStyle(fontSize: 10),
        shape: const StadiumBorder(),
      ),
      child: Text(label),
      onPressed: () {
        uploadImage();
      });

  @override
  void dispose() {
    _emailController.dispose();
    _passswordController.dispose();
    super.dispose();
  }

  void uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference postImageRef = storage.ref().child("mascotas");
    var timeKey = DateTime.now();
    final UploadTask uploadTask =
        postImageRef.child(timeKey.toString() + ".jpg").putFile(imagen);

    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    url = imageUrl.toString();
    newMascota(_emailController.text);
    // saveToDataBase(url);
  }

  Future<void> newMascota(String text) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    var mascota = Mascota(
        text,
        Animal.values[widget.animal.selected()].name,
        text,
        Sexo.values[widget.sexo.selected()].name,
        PetSize.values[widget.size.selected()].name,
        text,
        text,
        user!.uid,
        url);
    _mascotaService.addPet(mascota);
    setState(() {
      mascotas.add(mascota);
    });
  }

  // void saveToDataBase(String url) {
  //   var dbTmeKey = new DateTime.now();
  //   var formatDate = new DateFormat('MMM d, yyyy');
  //   var formatTime = new DateFormat('EEEE, hh:mm aaa');
  //   String date = formatDate.format(dbTmeKey);
  //   String time = formatTime.format(dbTmeKey);
  //   DatabaseReference ref = FirebaseDatabase.instance.ref();
  // }

  Future getImage() async {
    var tempImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imagen = File(tempImage!.path);
    });
  }

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
