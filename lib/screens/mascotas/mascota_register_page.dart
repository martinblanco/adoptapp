import 'dart:io';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/widgets/choice_widget.dart';
import 'package:adoptapp/widgets/custon_card_widget.dart';
import 'package:adoptapp/widgets/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class RegisterPet extends StatefulWidget {
  final String title = 'Registration';

  const RegisterPet({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final MascotasService _mascotaService = services.get<MascotasService>();
  List<Mascota> mascotas = [];
  late File imagen;
  late String url;
  final GlobalKey<FormState> _formPetKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passswordController = TextEditingController();
  late final bool _success = false;
  late String _userEmail;

  bool selectedCachorro = false;
  bool selectedVacunas = false;
  bool selectedTransito = false;
  bool selectedRaza = false;
  bool selectedRefugio = false;
  bool selectedPapeles = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Form(
        key: _formPetKey,
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
              CombinedCard(
                title: const Text(
                  'Animal',
                ),
                contenido: [
                  Choice<Animal>(
                    segments: const <ButtonSegment<Animal>>[
                      ButtonSegment<Animal>(
                          value: Animal.todos,
                          label: Text('Todos'),
                          icon: Icon(FontAwesomeIcons.paw)),
                      ButtonSegment<Animal>(
                          value: Animal.perro,
                          label: Text('Perros'),
                          icon: Icon(FontAwesomeIcons.dog)),
                      ButtonSegment<Animal>(
                          value: Animal.gato,
                          label: Text('Gatos'),
                          icon: Icon(FontAwesomeIcons.cat)),
                    ],
                    initialSelection: const {Animal.todos},
                    onSelectionChanged: (Set<Animal> value) {
                      // Maneja el valor seleccionado aquí
                      logger.i("Valor seleccionado: $value");
                    },
                    multiSelectionEnabled: false,
                  )
                ],
              ),
              CombinedCard(
                title: const Text(
                  'Sexo',
                ),
                contenido: [
                  Choice<Sexo>(
                    segments: const <ButtonSegment<Sexo>>[
                      ButtonSegment<Sexo>(
                          value: Sexo.todos,
                          label: Text('Todos'),
                          icon: Icon(FontAwesomeIcons.genderless)),
                      ButtonSegment<Sexo>(
                          value: Sexo.hembra,
                          label: Text('Hembra'),
                          icon: Icon(FontAwesomeIcons.venus)),
                      ButtonSegment<Sexo>(
                          value: Sexo.macho,
                          label: Text('Macho'),
                          icon: Icon(FontAwesomeIcons.mars)),
                    ],
                    initialSelection: const {Sexo.todos},
                    onSelectionChanged: (Set<Sexo> value) {
                      logger.i("Valor seleccionado: $value");
                    },
                    multiSelectionEnabled: false,
                  )
                ],
              ),
              CombinedCard(title: const Text('Tamaño'), contenido: [
                Choice<Sizes>(
                  segments: const <ButtonSegment<Sizes>>[
                    ButtonSegment<Sizes>(
                        value: Sizes.extraSmall, label: Text('XS')),
                    ButtonSegment<Sizes>(value: Sizes.small, label: Text('S')),
                    ButtonSegment<Sizes>(value: Sizes.medium, label: Text('M')),
                    ButtonSegment<Sizes>(value: Sizes.large, label: Text('L')),
                  ],
                  initialSelection: const {
                    Sizes.extraSmall,
                    Sizes.small,
                    Sizes.medium,
                    Sizes.large
                  },
                  onSelectionChanged: (Set<Sizes> value) {
                    logger.i("Valor seleccionado: $value");
                  },
                  multiSelectionEnabled: true,
                ),
              ]),
              CombinedCard(title: const Text("Otros Filtros"), contenido: [
                Column(children: [
                  Row(
                    children: [
                      CustomFilterChip(
                        text: "Cachorro",
                        selected: selectedCachorro,
                        onChanged: (bool value) {
                          setState(() {
                            selectedCachorro = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        text: "Vacunas",
                        selected: selectedVacunas,
                        onChanged: (bool value) {
                          setState(() {
                            selectedVacunas = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        text: "Raza",
                        selected: selectedRaza,
                        onChanged: (bool value) {
                          setState(() {
                            selectedRaza = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(children: [
                    CustomFilterChip(
                      text: "Transito",
                      selected: selectedTransito,
                      onChanged: (bool value) {
                        setState(() {
                          selectedTransito = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    CustomFilterChip(
                      text: "de Refugio",
                      selected: selectedRefugio,
                      onChanged: (bool value) {
                        setState(() {
                          selectedRefugio = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    CustomFilterChip(
                      text: "Papeles",
                      selected: selectedPapeles,
                      onChanged: (bool value) {
                        setState(() {
                          selectedPapeles = value;
                        });
                      },
                    ),
                  ])
                ]),
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
        text, text, text, false, text, text, text, text, user!.uid, url);
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
