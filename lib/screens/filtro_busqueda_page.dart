import 'package:adoptapp/widgets/choice_widget.dart';
import 'package:adoptapp/widgets/custon_card_widget.dart';
import 'package:adoptapp/widgets/dropdown_widget.dart';
import 'package:adoptapp/widgets/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Sizes { extraSmall, small, medium, large }

enum Animal { todos, perro, gato }

enum Sexo { todos, hembra, macho }

class FiltrosPage extends StatefulWidget {
  FiltrosPage({Key? key}) : super(key: key);

  @override
  _FiltrosPageState createState() => _FiltrosPageState();
}

class _FiltrosPageState extends State<FiltrosPage> {
  bool selectedCachorro = false;
  bool selectedVacunas = false;
  bool selectedTransito = false;
  bool selectedRaza = false;
  bool selectedRefugio = false;
  bool selectedPapeles = false;

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
              onPressed: () {},
            ),
            TextButton(
              child:
                  const Text('APLICAR', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(children: [
              const CombinedCard(
                title: Text("Ordenar por"),
                isSingle: true,
                contenido: DropDown(
                    textos: ['Mas Relevante', 'Mas Reciente', 'Mas Cercano']),
              ),
              const CombinedCard(
                title: Text("Fecha de creacion"),
                isSingle: true,
                contenido: DropDown(textos: [
                  'Todo',
                  'Ultimas 24hs',
                  'Ultimos 7 dias',
                  'Ultimos 30 dias'
                ]),
              ),
              CombinedCard(
                title: const Text(
                  'Animal',
                ),
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
                    initialSelection: {Animal.todos},
                    onSelectionChanged: (Set<Animal> value) {
                      // Maneja el valor seleccionado aquí
                      print("Valor seleccionado: $value");
                    },
                    multiSelectionEnabled: false,
                  )
                ],
              ),
              CombinedCard(
                title: Text(
                  'Sexo',
                ),
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
                    initialSelection: {Sexo.todos},
                    onSelectionChanged: (Set<Sexo> value) {
                      print("Valor seleccionado: $value");
                    },
                    multiSelectionEnabled: false,
                  )
                ],
              ),
              CombinedCard(title: Text('Tamaño'), contenido: [
                Choice<Sizes>(
                  segments: const <ButtonSegment<Sizes>>[
                    ButtonSegment<Sizes>(
                        value: Sizes.extraSmall, label: Text('XS')),
                    ButtonSegment<Sizes>(value: Sizes.small, label: Text('S')),
                    ButtonSegment<Sizes>(value: Sizes.medium, label: Text('M')),
                    ButtonSegment<Sizes>(value: Sizes.large, label: Text('L')),
                  ],
                  initialSelection: {
                    Sizes.extraSmall,
                    Sizes.small,
                    Sizes.medium,
                    Sizes.large
                  },
                  onSelectionChanged: (Set<Sizes> value) {
                    print("Valor seleccionado: $value");
                  },
                  multiSelectionEnabled: true,
                ),
              ]),
              CombinedCard(title: Text("Otros Filtros"), contenido: [
                Column(children: [
                  Row(
                    children: [
                      CustomFilterChip(
                        text: "Cachorro",
                        selected: selectedCachorro,
                        onChanged: (bool value) {
                          setState(() {
                            selectedCachorro = value;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      CustomFilterChip(
                        text: "Vacunas",
                        selected: selectedVacunas,
                        onChanged: (bool value) {
                          setState(() {
                            selectedVacunas = value;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      CustomFilterChip(
                        text: "Raza",
                        selected: selectedRaza,
                        onChanged: (bool value) {
                          setState(() {
                            selectedRaza = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(children: [
                    CustomFilterChip(
                      text: "Transito",
                      selected: selectedTransito,
                      onChanged: (bool value) {
                        setState(() {
                          selectedTransito = value;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    CustomFilterChip(
                      text: "de Refugio",
                      selected: selectedRefugio,
                      onChanged: (bool value) {
                        setState(() {
                          selectedRefugio = value;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    CustomFilterChip(
                      text: "Papeles",
                      selected: selectedPapeles,
                      onChanged: (bool value) {
                        setState(() {
                          selectedPapeles = value;
                        });
                      },
                    ),
                  ])
                ]),
              ]),
            ])));
  }
}
