import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Mascota {
  String user;
  String nombre;
  String edad;
  String sexo; //Hembra Macho
  String size; //Pequeño Mediano Grande Nose
  String fotoPerfil =
      "https://ichef.bbci.co.uk/news/800/cpsprodpb/15665/production/_107435678_perro1.jpg";
  bool isCachorro = false;
  bool isRaza = false;
  bool isTransito = false;
  bool isVacunas = false;
  String raza;
  String descripcion;
  List<String> requisitos = [];
  Set usersLiked = {};
  // ignore: unused_field
  late DatabaseReference _id;

  Mascota(this.nombre, this.edad, this.sexo, this.size, this.descripcion,
      this.raza, this.user, this.fotoPerfil);

  void likeMascota(User user) {
    if (usersLiked.contains(user.uid)) {
      usersLiked.remove(user.uid);
    } else {
      usersLiked.add(user.uid);
    }
    //this.update();
  }

  void setId(DatabaseReference id) {
    _id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'edad': edad,
      'sexo': sexo,
      'size': size,
      'descripcion': descripcion,
      'raza': raza,
      'usuario': user,
      'foto': fotoPerfil,
      'usersLiked': usersLiked.toList()
    };
  }
}

Mascota createMascota(record) {
  Map<String, dynamic> attributes = {
    'nombre': '',
    'edad': '',
    'sexo': '',
    'size': '',
    'descripcion': '',
    'raza': '',
    'usuario': '',
    'foto': '',
    'usersLiked': [],
  };

  record.forEach((key, value) => {attributes[key] = value});

  Mascota mascota = Mascota(
      attributes['nombre'],
      attributes['edad'],
      attributes['sexo'],
      attributes['size'],
      attributes['descripcion'],
      attributes['raza'],
      attributes['usuario'],
      attributes['foto']);

  mascota.usersLiked = Set.from(attributes['usersLiked']);

  return mascota;
}
