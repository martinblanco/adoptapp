import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

enum Sizes { extraSmall, small, medium, large }

enum Animal { todos, perro, gato }

enum Sexo { todos, hembra, macho }

class Mascota {
  String id = "";
  String user;
  String animal;
  String nombre;
  String edad;
  String sexo;
  String size;
  bool isCachorro = false;
  bool isRaza = false;
  bool isTransito = false;
  bool isVacunas = false;
  String raza;
  late String cachorro;
  String descripcion;
  int distancia = 0;
  List<String> requisitos = [];
  Set usersLiked = {};
  String fotoPerfil;
  List<String> fotos = [];

  Mascota(this.nombre, this.animal, this.edad, this.isCachorro, this.sexo,
      this.size, this.descripcion, this.raza, this.user, this.fotoPerfil) {
    fotos = [fotoPerfil, fotoPerfil];
  }

  void likeMascota(User user) {
    if (usersLiked.contains(user.uid)) {
      usersLiked.remove(user.uid);
    } else {
      usersLiked.add(user.uid);
    }
    //this.update();
  }

  void setId(DatabaseReference id) {}

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'animal': animal,
      'edad': edad,
      'cachorro': cachorro,
      'sexo': sexo,
      'size': size,
      'descripcion': descripcion,
      'raza': raza,
      'usuario': user,
      'foto': fotoPerfil,
      'usersLiked': usersLiked.toList()
    };
  }

  static const Map<String, IconData> _sexoIconMap = {
    "hembra": Icons.female,
    "macho": Icons.male,
  };

  static IconData getSexoIcon(String sexo) {
    return _sexoIconMap[sexo] ?? Icons.pets;
  }

  static const Map<String, String> _sizeIconMap = {
    "chico": "S",
    "mediano": "M",
    "grande": "L",
  };

  static String getSizeIcon(String size) {
    return _sizeIconMap[size] ?? "";
  }
}

Mascota createMascota(record) {
  Map<String, dynamic> attributes = {
    'nombre': '',
    'animal': '',
    'edad': '',
    'cachorro': '',
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
      attributes['animal'],
      attributes['edad'],
      attributes['cachorro'] == "true" ? true : false,
      attributes['sexo'],
      attributes['size'],
      attributes['descripcion'],
      attributes['raza'],
      attributes['usuario'],
      attributes['foto']);

  mascota.usersLiked = Set.from(attributes['usersLiked']);

  return mascota;
}
