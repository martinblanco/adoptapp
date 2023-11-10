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

  Future<void> _cargarProvincias() async {
    final jsonString =
        await rootBundle.loadString('assets/jsons/provincias.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    provincias = jsonList.map((e) => Provincia.fromJson(e)).toList();
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
                _futurePopup(),
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

  _futurePopup() {
    return FutureBuilder<void>(
      future: _cargarProvincias(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mientras se carga, puedes mostrar un indicador de carga o texto
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Si ocurre un error durante la carga, puedes mostrar un mensaje de error
          return Text('Error al cargar las provincias');
        } else {
          // Cuando la carga se completa, puedes mostrar el _popup() con las provincias
          return _popup();
        }
      },
    );
  }

  _popup() {
    Provincia selectedProvincia = provincias.isNotEmpty
        ? provincias.first
        : Provincia(name: 'Ciudad de Buenos Aires');
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
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
