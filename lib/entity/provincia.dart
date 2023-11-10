class Provincia {
  final String name;

  Provincia({required this.name});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(name: json['name']);
  }
}
