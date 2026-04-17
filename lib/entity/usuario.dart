import 'package:firebase_database/firebase_database.dart';
import 'package:adoptapp/entity/mascota.dart';

class RedSocial {
  final String tipo;
  final String usuario;

  const RedSocial({
    required this.tipo,
    required this.usuario,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'usuario': usuario,
    };
  }
}

class Usuario {
  String id = "";
  String mail;
  String userName;
  String descripcion;
  String fotoPerfil;
  bool isRefugio = false;
  late List<Mascota> mascotas = [];
  List<RedSocial> redes;
  List<RedSocial> donaciones;

  Usuario(
    this.mail,
    this.userName,
    this.isRefugio, {
    this.descripcion = '',
    this.fotoPerfil = '',
    List<RedSocial>? redes,
    List<RedSocial>? donaciones,
  })  : redes = redes ?? <RedSocial>[],
        donaciones = donaciones ?? <RedSocial>[];

  void setId(DatabaseReference id) {}

  Map<String, dynamic> toJson() {
    return {
      'nombre': userName,
      'mail': mail,
      'descripcion': descripcion,
      'fotoPerfil': fotoPerfil,
      'isRefugio': isRefugio,
      'mascotas': mascotas.toList(),
      'redes': redes.map((red) => red.toJson()).toList(),
      'donaciones': donaciones.map((donacion) => donacion.toJson()).toList(),
    };
  }
}

Usuario createUsuario(record) {
  Map<String, dynamic> attributes = {
    'nombre': '',
    'mail': '',
    'descripcion': '',
    'fotoPerfil': '',
    'isRefugio': false,
    'mascotas': [],
    'redes': [],
    'donaciones': [],
  };

  record.forEach((key, value) => {attributes[key] = value});

  final List<RedSocial> redesParseadas = _parseRedes(attributes['redes']);
  List<RedSocial> donacionesParseadas = _parseRedes(attributes['donaciones']);

  // Compatibilidad: si antes se guardaron donaciones en "redes", las movemos.
  if (donacionesParseadas.isEmpty && redesParseadas.isNotEmpty) {
    final legacyDonaciones =
        redesParseadas.where((red) => _isDonationType(red.tipo)).toList();
    if (legacyDonaciones.isNotEmpty) {
      donacionesParseadas = legacyDonaciones;
    }
  }

  Usuario usuario = Usuario(
    attributes['mail'],
    attributes['nombre'],
    attributes['isRefugio'],
    descripcion: attributes['descripcion'] ?? '',
    fotoPerfil: attributes['fotoPerfil'] ?? '',
    redes: redesParseadas.where((red) => !_isDonationType(red.tipo)).toList(),
    donaciones: donacionesParseadas,
  );
  usuario.mascotas = List.from(attributes['mascotas']);

  return usuario;
}

bool _isDonationType(String tipo) {
  return tipo == 'alias' || tipo == 'cbu' || tipo == 'cafecito';
}

List<RedSocial> _parseRedes(dynamic rawRedes) {
  if (rawRedes == null) {
    return <RedSocial>[];
  }

  if (rawRedes is List) {
    return rawRedes
        .whereType<Map>()
        .map((red) => _mapToRedSocial(Map<String, dynamic>.from(red)))
        .whereType<RedSocial>()
        .toList();
  }

  if (rawRedes is Map) {
    return rawRedes.values
        .whereType<Map>()
        .map((red) => _mapToRedSocial(Map<String, dynamic>.from(red)))
        .whereType<RedSocial>()
        .toList();
  }

  return <RedSocial>[];
}

RedSocial? _mapToRedSocial(Map<String, dynamic> redMap) {
  final String tipo = (redMap['tipo'] ?? '').toString().trim();
  final String usuario = (redMap['usuario'] ?? '').toString().trim();

  if (tipo.isEmpty || usuario.isEmpty) {
    return null;
  }

  return RedSocial(tipo: tipo, usuario: usuario);
}
