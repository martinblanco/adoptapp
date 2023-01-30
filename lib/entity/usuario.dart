import 'package:firebase_database/firebase_database.dart';
import 'package:adoptapp/entity/mascota.dart';

class Usuario {
  String mail;
  String userName;
  String isRefugio;
  late List<Mascota> mascotas = [];
  late DatabaseReference _id;

  Usuario(this.mail, this.userName, this.isRefugio);

  void setId(DatabaseReference id) {
    _id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': userName,
      'mail': mail,
      'isRefugio': isRefugio,
      'mascotas': mascotas.toList()
    };
  }
}

Usuario createUsuario(record) {
  Map<String, dynamic> attributes = {
    'nombre': '',
    'mail': '',
    'isRefugio': '',
    'mascotas': [],
  };

  record.forEach((key, value) => {attributes[key] = value});

  Usuario usuario = Usuario(
      attributes['nombre'], attributes['mail'], attributes['isRefugio']);
  usuario.mascotas = List.from(attributes['mascotas']);

  return usuario;
}
