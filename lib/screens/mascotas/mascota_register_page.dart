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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// Modelo para atributos de mascota
class _PetAttributes {
  bool cachorro = false;
  bool vacunas = false;
  bool transito = false;
  bool raza = false;
  bool castrado = false;
  bool papeles = false;

  void reset() {
    cachorro = vacunas = transito = raza = castrado = papeles = false;
  }
}

class RegisterPet extends StatefulWidget {
  const RegisterPet({Key? key}) : super(key: key);

  @override
  State<RegisterPet> createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final _mascotaService = services.get<MascotasService>();
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _animalCtrl = TextEditingController(text: Animal.perro.toString());
  final _sexoCtrl = TextEditingController(text: Sexo.hembra.toString());
  final _sizeCtrl = TextEditingController(text: Sizes.medium.toString());
  static const LatLng _defaultCenter = LatLng(-34.6037, -58.3816);
  LatLng? _ubicacionSeleccionada;

  late File? _imagen;
  late String _imageUrl;
  late _PetAttributes _attr;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imagen = null;
    _attr = _PetAttributes();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _edadCtrl.dispose();
    _animalCtrl.dispose();
    _sexoCtrl.dispose();
    _sizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poner en Adopción',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildImagePicker(),
              _buildTextField('Nombre', _nombreCtrl),
              _buildInfoCard(),
              _buildTextField('Edad', _edadCtrl),
              _buildLocationCard(),
              _buildSizeCard(),
              _buildTextField('Descripción', _descripcionCtrl, maxLines: 4),
              _buildAttributesCard(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() => Padding(
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
            child: _imagen != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imagen!, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Icon(Icons.add, size: 40, color: Colors.grey)),
          ),
        ),
      );

  Widget _buildTextField(String label, TextEditingController ctrl,
          {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextFormField(
              controller: ctrl,
              maxLines: maxLines,
              minLines: maxLines == 1 ? 1 : maxLines - 1,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2)),
                hintText: label,
                hintStyle: const TextStyle(color: Colors.orange),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Este campo no puede estar vacío' : null,
            ),
          ),
        ),
      );

  Widget _buildInfoCard() => CombinedCard(
        title: const Text('Información'),
        contenido: [
          Column(
            children: [
              Choice<Animal>(
                segments: const [
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
                onSelectionChanged: (v) => _animalCtrl.text = v.first.name,
                multiSelectionEnabled: false,
              ),
              Choice<Sexo>(
                segments: const [
                  ButtonSegment<Sexo>(
                      value: Sexo.hembra,
                      label: Text('Hembra'),
                      icon: Icon(FontAwesomeIcons.venus)),
                  ButtonSegment<Sexo>(
                      value: Sexo.macho,
                      label: Text('Macho'),
                      icon: Icon(FontAwesomeIcons.mars)),
                ],
                initialSelection: const {Sexo.hembra},
                onSelectionChanged: (v) => _sexoCtrl.text = v.first.name,
                multiSelectionEnabled: false,
              )
            ],
          )
        ],
      );

  Widget _buildSizeCard() => CombinedCard(
        title: const Text('Tamaño'),
        contenido: [
          Choice<Sizes>(
            segments: const [
              ButtonSegment<Sizes>(value: Sizes.extraSmall, label: Text('XS')),
              ButtonSegment<Sizes>(value: Sizes.small, label: Text('S')),
              ButtonSegment<Sizes>(value: Sizes.medium, label: Text('M')),
              ButtonSegment<Sizes>(value: Sizes.large, label: Text('L')),
            ],
            initialSelection: const {Sizes.medium},
            onSelectionChanged: (v) => _sizeCtrl.text = v.first.name,
            multiSelectionEnabled: false,
          ),
        ],
      );

  Widget _buildLocationCard() => CombinedCard(
        title: const Text('Ubicación aproximada'),
        contenido: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child:
                    Text('Tocá el mapa para marcar una ubicación aproximada.'),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 220,
                  width: 320,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _ubicacionSeleccionada ?? _defaultCenter,
                      zoom: _ubicacionSeleccionada == null ? 10 : 13,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    onTap: (pos) =>
                        setState(() => _ubicacionSeleccionada = pos),
                    markers: {
                      if (_ubicacionSeleccionada != null)
                        Marker(
                          markerId: const MarkerId('ubicacion_mascota'),
                          position: _ubicacionSeleccionada!,
                        ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _ubicacionSeleccionada == null
                    ? 'Sin ubicación seleccionada'
                    : 'Lat: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(5)}, Lng: ${_ubicacionSeleccionada!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      );

  Widget _buildAttributesCard() => CombinedCard(
        title: const Text('Otros Datos'),
        contenido: [
          Column(
            children: [
              _buildAttributeRow([
                ('Cachorro', () => _attr.cachorro),
                ('Vacunas', () => _attr.vacunas),
                ('Raza', () => _attr.raza),
              ]),
              _buildAttributeRow([
                ('Tránsito', () => _attr.transito),
                ('Castrado', () => _attr.castrado),
                ('Papeles', () => _attr.papeles),
              ]),
            ],
          )
        ],
      );

  Widget _buildAttributeRow(List<(String, bool Function())> items) => Row(
        children: [
          for (var (label, getter) in items) ...[
            CustomFilterChip(
              text: label,
              selected: getter(),
              onChanged: (v) => setState(() => _updateAttribute(label, v)),
            ),
            if (items.indexOf((label, getter)) < items.length - 1)
              const SizedBox(width: 8),
          ]
        ],
      );

  void _updateAttribute(String label, bool value) {
    switch (label) {
      case 'Cachorro':
        _attr.cachorro = value;
        break;
      case 'Vacunas':
        _attr.vacunas = value;
        break;
      case 'Raza':
        _attr.raza = value;
        break;
      case 'Tránsito':
        _attr.transito = value;
        break;
      case 'Castrado':
        _attr.castrado = value;
        break;
      case 'Papeles':
        _attr.papeles = value;
        break;
    }
  }

  Widget _buildSubmitButton() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: Colors.orangeAccent,
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: const StadiumBorder(),
          ),
          onPressed: _isUploading ? null : uploadImage,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
              : const Text('Agregar Mascota'),
        ),
      );

  Future<void> uploadImage() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagen == null) {
      _showSnackBar('Seleccione una imagen primero');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        _imagen!.path,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) throw Exception('No se pudo comprimir la imagen');

      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('mascotas/$filename');

      final upload =
          ref.putData(compressed, SettableMetadata(contentType: 'image/jpeg'));
      await upload;

      _imageUrl = await ref.getDownloadURL();
      await _savePet();
      _showSnackBar('Mascota agregada correctamente');
      _resetForm();
    } catch (e) {
      logger.e('Error: $e');
      _showSnackBar('Error: ${e.toString().substring(0, 50)}');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _savePet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final mascota = Mascota(
      _nombreCtrl.text,
      _animalCtrl.text,
      _edadCtrl.text,
      _attr.cachorro,
      _sexoCtrl.text,
      _sizeCtrl.text,
      _descripcionCtrl.text,
      _ubicacionSeleccionada?.latitude,
      _ubicacionSeleccionada?.longitude,
      _attr.castrado,
      _attr.papeles,
      _attr.raza,
      _attr.vacunas,
      _attr.transito,
      user.uid,
      _imageUrl,
    );

    await _mascotaService.addPet(mascota);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _imagen = null;
      _nombreCtrl.clear();
      _descripcionCtrl.clear();
      _edadCtrl.clear();
      _ubicacionSeleccionada = null;
      _attr.reset();
    });
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  Future<void> getImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null) {
      setState(() => _imagen = File(image.path));
    }
  }
}
