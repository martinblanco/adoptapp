import 'package:firebase_database/firebase_database.dart';
import 'package:adoptapp/mascota.dart';

class Usuario {
  String mail;
  String userName;
  String isRefugio;
  String uid;
  late List<Mascota> mascotas = [];
  // ignore: unused_field
  late DatabaseReference _id;

  Usuario(this.mail, this.userName, this.isRefugio, this.uid);

  void setId(DatabaseReference id) {
    _id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': userName,
      'mail': mail,
      'isRefugio': isRefugio,
      'uid': uid,
      'mascotas': mascotas.toList()
    };
  }
}

Usuario createUsuario(record) {
  Map<String, dynamic> attributes = {
    'nombre': '',
    'mail': '',
    'isRefugio': '',
    'uid': '',
    'mascotas': [],
  };

  record.forEach((key, value) => {attributes[key] = value});

  Usuario usuario = Usuario(attributes['nombre'], attributes['mail'],
      attributes['isRefugio'], attributes['uid']);

  usuario.mascotas = List.from(attributes['mascotas']);

  return usuario;
}
