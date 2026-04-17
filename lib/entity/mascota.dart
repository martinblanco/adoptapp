import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Sizes { extraSmall, small, medium, large }

enum Animal { todos, perro, gato }

enum Sexo { todos, hembra, macho }

class MascotaEstado {
  static const String enAdopcion = 'en_adopcion';
  static const String adoptado = 'adoptado';
  static const String borrado = 'borrado';
}

class Mascota {
  String id = "";
  String user;
  String animal;
  String nombre;
  String descripcion;
  double? latitud;
  double? longitud;
  String edad;
  String sexo;
  String size;
  String estado = MascotaEstado.enAdopcion;
  bool isCachorro = false;
  bool isRaza = false;
  bool isTransito = false;
  bool isVacunas = false;
  bool isCastrado = false;
  bool isPapeles = false;

  int distancia = 0;
  List<String> requisitos = [];
  String fotoPerfil;
  List<String> fotos = [];

  Mascota(
      this.nombre,
      this.animal,
      this.edad,
      this.isCachorro,
      this.sexo,
      this.size,
      this.descripcion,
      this.latitud,
      this.longitud,
      this.isCastrado,
      this.isPapeles,
      this.isRaza,
      this.isVacunas,
      this.isTransito,
      this.user,
      this.fotoPerfil) {
    fotos = [fotoPerfil, fotoPerfil];
  }

  void setId(DatabaseReference id) {}

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'animal': animal,
      'edad': edad,
      'cachorro': isCachorro,
      'sexo': sexo,
      'size': size,
      'estado': estado,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'castrado': isCastrado,
      'papeles': isPapeles,
      'raza': isRaza,
      'vacunas': isVacunas,
      'transito': isTransito,
      'usuario': user,
      'foto': fotoPerfil,
    };
  }

  static const Map<String, IconData> _animalIconMap = {
    "perro": FontAwesomeIcons.dog,
    "gato": FontAwesomeIcons.cat,
  };

  static IconData getAnimalIcon(String sexo) {
    return _animalIconMap[sexo] ?? Icons.pets;
  }

  static const Map<String, IconData> _sexoIconMap = {
    "hembra": Icons.female,
    "macho": Icons.male,
  };

  static IconData getSexoIcon(String sexo) {
    return _sexoIconMap[sexo] ?? Icons.pets;
  }

  static const Map<String, String> _sexoTextMap = {
    "hembra": "Hembra",
    "macho": "Macho",
  };

  static String getSexoString(String sexo) {
    return _sexoTextMap[sexo] ?? "";
  }

  static const Map<String, String> _sizeIconMap = {
    "extraSmall": "Mini",
    "small": "Chico",
    "medium": "Mediano",
    "large": "Grande",
  };

  static String getSizeIcon(String size) {
    return _sizeIconMap[size] ?? "";
  }
}

Mascota createMascota(record) {
  double? toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> attributes = {
    'nombre': '',
    'animal': '',
    'edad': '',
    'cachorro': false,
    'sexo': '',
    'size': '',
    'estado': MascotaEstado.enAdopcion,
    'descripcion': '',
    'latitud': null,
    'longitud': null,
    'castrado': false,
    'papeles': false,
    'raza': false,
    'vacunas': false,
    'transito': false,
    'usuario': '',
    'foto': '',
  };

  record.forEach((key, value) => {attributes[key] = value});

  Mascota mascota = Mascota(
      attributes['nombre'],
      attributes['animal'],
      attributes['edad'],
      attributes['cachorro'],
      attributes['sexo'],
      attributes['size'],
      attributes['descripcion'],
      toNullableDouble(attributes['latitud']),
      toNullableDouble(attributes['longitud']),
      attributes['castrado'],
      attributes['papeles'],
      attributes['raza'],
      attributes['vacunas'],
      attributes['transito'],
      attributes['usuario'],
      attributes['foto']);

  mascota.estado =
      (attributes['estado'] ?? MascotaEstado.enAdopcion).toString();

  return mascota;
}
