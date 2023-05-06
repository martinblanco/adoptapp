import 'dart:convert';

import 'package:adoptapp/page/filtro_busqueda_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../entity/provincia.dart';

class FiltroPanel extends StatefulWidget {
  @override
  _FiltroPanelState createState() => _FiltroPanelState();
}

class _FiltroPanelState extends State<FiltroPanel> {
  List<Provincia> provincias = [];
  bool isSelectedPerros = false;
  bool isSelectedGatos = false;
  Provincia selectedProvincia =
      new Provincia(nombre: 'Ciudad de Buenos Aires', tipo: 'tipo');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.amber),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
              Colors.black.withOpacity(.4),
              Colors.black.withOpacity(.2),
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => FiltrosPage(),
                      ),
                    );
                  },
                ),
                _popup(),
                _popup(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _filtroPerros(),
                _filtroGatos(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _filtroPerros() {
    return FilterChip(
        avatar: Icon(FontAwesomeIcons.dog),
        label: Text('Perros'),
        selected: isSelectedPerros,
        backgroundColor: Colors.blue,
        selectedColor: Colors.red,
        onSelected: (bool value) {
          isSelectedPerros = !isSelectedPerros;
        });
  }

  _filtroGatos() {
    return FilterChip(
        avatar: Icon(FontAwesomeIcons.cat),
        label: Text('Gatos'),
        selected: isSelectedGatos,
        backgroundColor: Colors.blue,
        selectedColor: Colors.red,
        onSelected: (bool value) {
          isSelectedGatos = !isSelectedGatos;
        });
  }

  _popup() {
    return DropdownButton<Provincia>(
      value: selectedProvincia,
      onChanged: (Provincia? newValue) {
        setState(() {
          selectedProvincia = newValue!;
        });
      },
      items: provincias.map<DropdownMenuItem<Provincia>>((Provincia value) {
        return DropdownMenuItem<Provincia>(
          value: value,
          child: Text(value.nombre),
        );
      }).toList(),
    );
  }

  Future<void> _cargarProvincias() async {
    final String data = await rootBundle.loadString('assets/provincias.json');
    final List<dynamic> jsonList = json.decode(data);
    provincias = jsonList.map((e) => Provincia.fromJson(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    _cargarProvincias();
  }
}
