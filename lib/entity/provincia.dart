class Provincia {
  final String nombre;

  Provincia({required this.nombre});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(nombre: json['name']);
  }
}
