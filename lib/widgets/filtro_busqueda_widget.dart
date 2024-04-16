import 'dart:convert';
import 'package:adoptapp/screens/filtro_busqueda_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../entity/provincia.dart';

class FiltroPanel extends StatefulWidget {
  const FiltroPanel({Key? key}) : super(key: key);

  @override
  _FiltroPanelState createState() => _FiltroPanelState();
}

class _FiltroPanelState extends State<FiltroPanel> {
  late Provincia selectedProvincia = Provincia(name: "C.A.B.A");
  List<Provincia> provincias = [];
  bool isSelectedPerros = true;
  bool isSelectedGatos = true;

  @override
  void initState() {
    super.initState();
    cargarProvincias();
  }

  Future<void> cargarProvincias() async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/jsons/provincias.json');
    List<dynamic> jsonList = json.decode(jsonString);
    List<Provincia> listaProvincias =
        jsonList.map((json) => Provincia.fromJson(json)).toList();
    setState(() {
      provincias = listaProvincias;
      selectedProvincia = provincias.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.orangeAccent[100]),
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
        backgroundColor: Colors.orangeAccent,
        selectedColor: Colors.orange,
        onSelected: (bool value) {
          setState(() {
            isSelectedPerros = !isSelectedPerros;
          });
        });
  }

  _filtroGatos() {
    return FilterChip(
        label: const Icon(FontAwesomeIcons.cat),
        selected: isSelectedGatos,
        backgroundColor: Colors.orangeAccent,
        selectedColor: Colors.orange,
        onSelected: (bool value) {
          setState(() {
            isSelectedGatos = !isSelectedGatos;
          });
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
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
