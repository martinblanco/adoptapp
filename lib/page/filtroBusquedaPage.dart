import 'package:adoptapp/widget/custonCardWidget.dart';
import 'package:adoptapp/widget/selectorCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../entity/mascota.dart';

class FiltrosPage extends StatefulWidget {
  late SelectorCard animal;

  @override
  _FiltrosPageState createState() => _FiltrosPageState();
}

class _FiltrosPageState extends State<FiltrosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
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
        backgroundColor: Colors.teal,
        actions: [
          TextButton(
            child: const Text('LIMPIAR'),
            onPressed: () {
              print(widget.animal.selected());
              print(Animal.values[widget.animal.selected()].name);
            },
          ),
          TextButton(
            child: const Text('APLICAR'),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            CustomCard(
              children: [
                const Text(
                  'Ordenar por',
                ),
                DropDown(),
              ],
            ),
            CustomCard(
              children: [
                const Text(
                  'Fecha de publicacion',
                ),
                DropDownDos(),
              ],
            ),
            widget.animal = SelectorCard(
                title: "Animal",
                texts: const ["Perro", "Gato"],
                icons: const [FontAwesomeIcons.dog, FontAwesomeIcons.cat]),
            SelectorCard(
                title: "Sexo",
                texts: const ["Hembra", "Macho"],
                icons: const [FontAwesomeIcons.venus, FontAwesomeIcons.mars]),
            SelectorCard(title: "Tamaño", texts: const [
              "Chico",
              "Mediano",
              "Grande"
            ], icons: const [
              FontAwesomeIcons.s,
              FontAwesomeIcons.m,
              FontAwesomeIcons.l
            ]),
            CustomCard(children: [
              CheckBoxList(
                children: const ['Cachorro', 'Raza', 'Vacunado', 'Transito'],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class CheckBoxList extends StatefulWidget {
  CheckBoxList({required this.children}) {
    this.values = List.generate(children.length, (index) => false);
  }
  final List<String> children;
  // final int count;
  late final List<bool> values;
  @override
  _CheckBoxListState createState() => _CheckBoxListState();
}

class _CheckBoxListState extends State<CheckBoxList> {
  @override
  Widget build(BuildContext context) {
    var children = widget.children;
    var values = widget.values;
    return Column(
        children: children.map((element) {
      int index = children.indexOf(element);
      return CheckboxListTile(
        activeColor: Colors.teal,
        title: Text(
          element,
        ),
        value: values[index],
        onChanged: (bool? value) {
          setState(() {
            values[index] = value!;
          });
        },
      );
    }).toList());
  }
}

class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String dropdownValue = 'Mas cercano';
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: dropdownValue,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      isExpanded: true,
      items: ['Mas cercano', 'Mas reciente']
          .map((e) => DropdownMenuItem(
                child: Text(e),
                value: e,
              ))
          .toList(),
      underline: Container(
        height: 3,
        color: Colors.teal,
      ),
    );
  }
}

class DropDownDos extends StatefulWidget {
  @override
  _DropDownStates createState() => _DropDownStates();
}

class _DropDownStates extends State<DropDownDos> {
  String dropdownValue = 'Todo';
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: dropdownValue,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      isExpanded: true,
      items: ['Todo', 'Ultimas 24hs', 'Ultimos 7 dias', 'Ultimos 30 dias']
          .map((e) => DropdownMenuItem(
                child: Text(e),
                value: e,
              ))
          .toList(),
      underline: Container(
        height: 3,
        color: Colors.teal,
      ),
    );
  }
}
