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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

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
  File? imagen;
  late String url;
  final GlobalKey<FormState> _formPetKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController _passswordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  final TextEditingController _animalController =
      TextEditingController(text: Animal.perro.toString());
  final TextEditingController _sexoController =
      TextEditingController(text: Sexo.hembra.toString());
  final TextEditingController _SizeController =
      TextEditingController(text: Sizes.medium.toString());

  bool _success = false;
  late String _userEmail;

  bool selectedCachorro = false;
  bool selectedVacunas = false;
  bool selectedTransito = false;
  bool selectedRaza = false;
  bool selectedCastrado = false;
  bool selectedPapeles = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Poner en Adopcion',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Form(
          key: _formPetKey,
          child: ListView(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: getImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: imagen != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                imagen!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),
                buildTextField('Nombre', _nombreController),
                CombinedCard(
                    title: const Text(
                      'Informacion',
                    ),
                    contenido: [
                      Column(
                        children: [
                          Choice<Animal>(
                            segments: const <ButtonSegment<Animal>>[
                              ButtonSegment<Animal>(
                                  value: Animal.perro,
                                  label: Text('Perro'),
                                  icon: Icon(FontAwesomeIcons.dog)),
                              ButtonSegment<Animal>(
                                  value: Animal.gato,
                                  label: Text('Gato'),
                                  icon: Icon(FontAwesomeIcons.cat)),
                            ],
                            initialSelection: const {Animal.perro},
                            onSelectionChanged: (Set<Animal> value) {
                              _animalController.text = value.first.name;
                              logger
                                  .i("Valor seleccionado: ${value.first.name}");
                            },
                            multiSelectionEnabled: false,
                          ),
                          Choice<Sexo>(
                            segments: const <ButtonSegment<Sexo>>[
                              ButtonSegment<Sexo>(
                                  value: Sexo.hembra,
                                  label: Text('Hembra'),
                                  icon: Icon(FontAwesomeIcons.venus)),
                              ButtonSegment<Sexo>(
                                  value: Sexo.macho,
                                  label: Text('Macho'),
                                  icon: Icon(FontAwesomeIcons.mars)),
                            ],
                            initialSelection: const {Sexo.macho},
                            onSelectionChanged: (Set<Sexo> value) {
                              _sexoController.text = value.first.name;
                              logger
                                  .i("Valor seleccionado: ${value.first.name}");
                            },
                            multiSelectionEnabled: false,
                          )
                        ],
                      )
                    ]),
                buildTextField('Edad', _edadController),
                CombinedCard(title: const Text('Tamaño'), contenido: [
                  Choice<Sizes>(
                    segments: const <ButtonSegment<Sizes>>[
                      ButtonSegment<Sizes>(
                          value: Sizes.extraSmall, label: Text('XS')),
                      ButtonSegment<Sizes>(
                          value: Sizes.small, label: Text('S')),
                      ButtonSegment<Sizes>(
                          value: Sizes.medium, label: Text('M')),
                      ButtonSegment<Sizes>(
                          value: Sizes.large, label: Text('L')),
                    ],
                    initialSelection: const {Sizes.medium},
                    onSelectionChanged: (Set<Sizes> value) {
                      _SizeController.text = value.first.name;
                      logger.i("Valor seleccionado: ${value.first.name}");
                    },
                    multiSelectionEnabled: false,
                  ),
                ]),
                buildTextFieldBig('Descripcion', _descripcionController),
                CombinedCard(title: const Text("Otros Datos"), contenido: [
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
                        text: "Castrado",
                        selected: selectedCastrado,
                        onChanged: (bool value) {
                          setState(() {
                            selectedCastrado = value;
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
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController textController) =>
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: TextFormField(
                focusNode: FocusNode(),
                controller: textController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange ?? Colors.orange),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange ?? Colors.orange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  hintText: label,
                  hintStyle: TextStyle(color: Colors.orange),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 8.0),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede estar vacio';
                  }
                  return null;
                },
              ),
            ),
          ));

  Widget buildTextFieldBig(
          String label, TextEditingController textController) =>
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: TextFormField(
                focusNode: FocusNode(),
                controller: textController,
                maxLines: 5,
                minLines: 4,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey[400] ?? Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey[600] ?? Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  hintText: label,
                  hintStyle: TextStyle(color: Colors.orange),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 1.0, vertical: 8.0),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo no puede estar vacio';
                  }
                  return null;
                },
              ),
            ),
          ));

  Widget buildBotton(String label) => TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.orangeAccent,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: const StadiumBorder(),
      ),
      child: Text(label),
      onPressed: () {
        uploadImage();
      });

  @override
  void dispose() {
    _passswordController.dispose();
    super.dispose();
  }

  Future<void> uploadImage() async {
    try {
      if (imagen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleccione una imagen primero')));
        return;
      }
      // Compress to bytes (better control que imageQuality)
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
        imagen!.path,
        quality: 70, // ajustá entre 50-85 según calidad/tamaño deseado
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        throw Exception('No se pudo comprimir la imagen');
      }

      FirebaseStorage storage = FirebaseStorage.instance;
      final String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference postImageRef = storage.ref().child("mascotas/$filename");

      // mostrar progreso (opcional)
      final UploadTask uploadTask = postImageRef.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snap) {
        final progress = (snap.bytesTransferred / snap.totalBytes) * 100;
        // opcional: setState para mostrar progreso en UI
        logger.i('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      url = imageUrl;
      await newMascota();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Imagen subida')));
    } catch (e) {
      logger.e('uploadImage error');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error subiendo imagen')));
    }
  }

  Future<void> newMascota() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    var mascota = Mascota(
        _nombreController.text,
        _animalController.text,
        _edadController.text,
        selectedCachorro,
        _sexoController.text,
        _SizeController.text,
        _descripcionController.text,
        selectedCastrado,
        selectedPapeles,
        selectedRaza,
        selectedVacunas,
        selectedTransito,
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
    var tempImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // compresión ligera si no usás flutter_image_compress
      maxWidth: 1200,
    );
    if (tempImage == null) return;
    setState(() {
      imagen = File(tempImage.path);
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
