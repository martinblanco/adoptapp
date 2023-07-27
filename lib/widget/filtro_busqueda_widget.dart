import 'dart:convert';
import 'package:adoptapp/page/filtro_busqueda_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../entity/provincia.dart';

class FiltroPanel extends StatefulWidget {
  const FiltroPanel({Key? key}) : super(key: key);

  @override
  _FiltroPanelState createState() => _FiltroPanelState();
}

class _FiltroPanelState extends State<FiltroPanel> {
  List<Provincia> provincias = [];
  bool isSelectedPerros = true;
  bool isSelectedGatos = true;
  Provincia selectedProvincia = Provincia(nombre: 'Ciudad de Buenos Aires');

  @override
  void initState() {
    super.initState();
    _cargarProvincias();
  }

  Future<void> _cargarProvincias() async {
    provincias = json
        .decode(await rootBundle.loadString('assets/jsons/provincias.json'))
        .map((e) => Provincia.fromJson(e))
        .toList();
  }

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
                  icon: const Icon(Icons.filter_list),
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
        label: const Icon(FontAwesomeIcons.dog),
        selected: isSelectedPerros,
        backgroundColor: Colors.blue,
        selectedColor: Colors.red,
        onSelected: (bool value) {
          isSelectedPerros = !isSelectedPerros;
        });
  }

  _filtroGatos() {
    return FilterChip(
        label: const Icon(FontAwesomeIcons.cat),
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
}
