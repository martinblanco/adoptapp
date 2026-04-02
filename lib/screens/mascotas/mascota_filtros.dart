import 'package:adoptapp/entity/mascota.dart';

class FiltrosMascota {
  String ordenarPor;
  String fechaCreacion;
  Animal animal;
  Sexo sexo;
  Set<Sizes> sizes;
  bool cachorro;
  bool vacunas;
  bool transito;
  bool raza;
  bool refugio;
  bool papeles;
  String provincia;
  String tipo;
  int edad;
  Sizes size;
  bool perros;
  bool gatos;

  FiltrosMascota({
    this.ordenarPor = 'Mas Relevante',
    this.fechaCreacion = 'Todo',
    this.animal = Animal.todos,
    this.sexo = Sexo.todos,
    Set<Sizes>? sizes,
    this.cachorro = false,
    this.vacunas = false,
    this.transito = false,
    this.raza = false,
    this.refugio = false,
    this.papeles = false,
    this.provincia = '',
    this.tipo = '',
    this.edad = 0,
    this.size = Sizes.extraSmall,
    this.perros = false,
    this.gatos = false,
  }) : sizes =
            sizes ?? {Sizes.extraSmall, Sizes.small, Sizes.medium, Sizes.large};

  FiltrosMascota copyWith({
    String? ordenarPor,
    String? fechaCreacion,
    Animal? animal,
    Sexo? sexo,
    Set<Sizes>? sizes,
    bool? cachorro,
    bool? vacunas,
    bool? transito,
    bool? raza,
    bool? refugio,
    bool? papeles,
    String? provincia,
    String? tipo,
    int? edad,
    Sizes? size,
    bool? perros,
    bool? gatos,
  }) {
    return FiltrosMascota(
      ordenarPor: ordenarPor ?? this.ordenarPor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      animal: animal ?? this.animal,
      sexo: sexo ?? this.sexo,
      sizes: sizes ?? Set.from(this.sizes),
      cachorro: cachorro ?? this.cachorro,
      vacunas: vacunas ?? this.vacunas,
      transito: transito ?? this.transito,
      raza: raza ?? this.raza,
      refugio: refugio ?? this.refugio,
      papeles: papeles ?? this.papeles,
      provincia: provincia ?? this.provincia,
      tipo: tipo ?? this.tipo,
      edad: edad ?? this.edad,
      size: size ?? this.size,
      perros: perros ?? this.perros,
      gatos: gatos ?? this.gatos,
    );
  }

  void reset() {
    perros = false;
    gatos = false;
    provincia = '';
    animal = Animal.todos;
    sexo = Sexo.todos;
    sizes = {};
    cachorro = false;
    vacunas = false;
    transito = false;
    raza = false;
    refugio = false;
    papeles = false;
    edad = 0;
    size = Sizes.extraSmall;
  }

  Map<String, dynamic> toMap() {
    return {
      'provincia': provincia,
      'tipo': tipo,
      'edad': edad,
      'size': size,
      'ordenarPor': ordenarPor,
      'fechaCreacion': fechaCreacion,
      'animal': animal,
      'sexo': sexo,
      'sizes': sizes,
      'cachorro': cachorro,
      'vacunas': vacunas,
      'transito': transito,
      'raza': raza,
      'refugio': refugio,
      'papeles': papeles,
      'perros': perros,
      'gatos': gatos,
    };
  }
}
