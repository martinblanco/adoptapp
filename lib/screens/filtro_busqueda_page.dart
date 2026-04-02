import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/mascotas/mascota_filtros.dart';
import 'package:adoptapp/widgets/choice_widget.dart';
import 'package:adoptapp/widgets/custon_card_widget.dart';
import 'package:adoptapp/widgets/dropdown_widget.dart';
import 'package:adoptapp/widgets/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class FiltrosPage extends StatefulWidget {
  final FiltrosMascota filtrosActuales;

  const FiltrosPage({Key? key, required this.filtrosActuales})
      : super(key: key);

  @override
  _FiltrosPageState createState() => _FiltrosPageState();
}

class _FiltrosPageState extends State<FiltrosPage> {
  late FiltrosMascota _filtros;

  @override
  void initState() {
    super.initState();
    _filtros = widget.filtrosActuales.copyWith(
      sizes: Set.from(widget.filtrosActuales.sizes),
    );
  }

  void _aplicarFiltros() {
    // Normaliza lo elegido en la página avanzada hacia los bools que usa el grid
    final filtrosAplicados = _filtros.copyWith(
      perros:
          _filtros.animal == Animal.perro || _filtros.animal == Animal.todos,
      gatos: _filtros.animal == Animal.gato || _filtros.animal == Animal.todos,
    );

    Navigator.pop(context, filtrosAplicados);
  }

  void _limpiarFiltros() {
    setState(() {
      _filtros = FiltrosMascota();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Filtros',
            style: TextStyle(color: Colors.white),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20.0,
            ),
          ),
          backgroundColor: Colors.orange,
          actions: [
            TextButton(
              child:
                  const Text('LIMPIAR', style: TextStyle(color: Colors.white)),
              onPressed: _limpiarFiltros,
            ),
            TextButton(
              child:
                  const Text('APLICAR', style: TextStyle(color: Colors.white)),
              onPressed: _aplicarFiltros,
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(children: [
              CombinedCard(
                title: const Text("Ordenar por"),
                isSingle: true,
                contenido: DropDown(
                  textos: const [
                    'Mas Relevante',
                    'Mas Reciente',
                    'Mas Cercano'
                  ],
                  initialValue: _filtros.ordenarPor,
                  onChanged: (value) {
                    setState(() {
                      _filtros.ordenarPor = value;
                    });
                  },
                ),
              ),
              CombinedCard(
                title: const Text("Fecha de creacion"),
                isSingle: true,
                contenido: DropDown(
                  textos: const [
                    'Todo',
                    'Ultimas 24hs',
                    'Ultimos 7 dias',
                    'Ultimos 30 dias'
                  ],
                  initialValue: _filtros.fechaCreacion,
                  onChanged: (value) {
                    setState(() {
                      _filtros.fechaCreacion = value;
                    });
                  },
                ),
              ),
              CombinedCard(
                title: const Text('Animal'),
                contenido: [
                  Choice<Animal>(
                    segments: const <ButtonSegment<Animal>>[
                      ButtonSegment<Animal>(
                          value: Animal.todos,
                          label: Text('Todos'),
                          icon: Icon(FontAwesomeIcons.paw)),
                      ButtonSegment<Animal>(
                          value: Animal.perro,
                          label: Text('Perros'),
                          icon: Icon(FontAwesomeIcons.dog)),
                      ButtonSegment<Animal>(
                          value: Animal.gato,
                          label: Text('Gatos'),
                          icon: Icon(FontAwesomeIcons.cat)),
                    ],
                    initialSelection: {_filtros.animal},
                    onSelectionChanged: (Set<Animal> value) {
                      setState(() {
                        _filtros.animal = value.first;
                      });
                      logger.i("Animal seleccionado: ${value.first}");
                    },
                    multiSelectionEnabled: false,
                  )
                ],
              ),
              CombinedCard(
                title: const Text('Sexo'),
                contenido: [
                  Choice<Sexo>(
                    segments: const <ButtonSegment<Sexo>>[
                      ButtonSegment<Sexo>(
                          value: Sexo.todos,
                          label: Text('Todos'),
                          icon: Icon(FontAwesomeIcons.genderless)),
                      ButtonSegment<Sexo>(
                          value: Sexo.hembra,
                          label: Text('Hembra'),
                          icon: Icon(FontAwesomeIcons.venus)),
                      ButtonSegment<Sexo>(
                          value: Sexo.macho,
                          label: Text('Macho'),
                          icon: Icon(FontAwesomeIcons.mars)),
                    ],
                    initialSelection: {_filtros.sexo},
                    onSelectionChanged: (Set<Sexo> value) {
                      setState(() {
                        _filtros.sexo = value.first;
                      });
                      logger.i("Sexo seleccionado: ${value.first}");
                    },
                    multiSelectionEnabled: false,
                  )
                ],
              ),
              CombinedCard(title: const Text('Tamaño'), contenido: [
                Choice<Sizes>(
                  segments: const <ButtonSegment<Sizes>>[
                    ButtonSegment<Sizes>(
                        value: Sizes.extraSmall, label: Text('XS')),
                    ButtonSegment<Sizes>(value: Sizes.small, label: Text('S')),
                    ButtonSegment<Sizes>(value: Sizes.medium, label: Text('M')),
                    ButtonSegment<Sizes>(value: Sizes.large, label: Text('L')),
                  ],
                  initialSelection: _filtros.sizes,
                  onSelectionChanged: (Set<Sizes> value) {
                    setState(() {
                      _filtros.sizes = value;
                    });
                    logger.i("Tamaños seleccionados: $value");
                  },
                  multiSelectionEnabled: true,
                ),
              ]),
              CombinedCard(title: const Text("Otros Filtros"), contenido: [
                Column(children: [
                  Row(
                    children: [
                      CustomFilterChip(
                        text: "Cachorro",
                        selected: _filtros.cachorro,
                        onChanged: (bool value) {
                          setState(() {
                            _filtros.cachorro = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        text: "Vacunas",
                        selected: _filtros.vacunas,
                        onChanged: (bool value) {
                          setState(() {
                            _filtros.vacunas = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        text: "Raza",
                        selected: _filtros.raza,
                        onChanged: (bool value) {
                          setState(() {
                            _filtros.raza = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(children: [
                    CustomFilterChip(
                      text: "Transito",
                      selected: _filtros.transito,
                      onChanged: (bool value) {
                        setState(() {
                          _filtros.transito = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    CustomFilterChip(
                      text: "de Refugio",
                      selected: _filtros.refugio,
                      onChanged: (bool value) {
                        setState(() {
                          _filtros.refugio = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    CustomFilterChip(
                      text: "Papeles",
                      selected: _filtros.papeles,
                      onChanged: (bool value) {
                        setState(() {
                          _filtros.papeles = value;
                        });
                      },
                    ),
                  ])
                ]),
              ]),
            ])));
  }
}
