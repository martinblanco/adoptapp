class Provincia {
  final String nombre;
  final String tipo;

  Provincia({required this.nombre, required this.tipo});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(nombre: json['nombre'], tipo: json['tipo']);
  }
}
