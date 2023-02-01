import 'package:adoptapp/widget/filtro_busqueda_widget.dart';
import 'package:adoptapp/widget/mascota_card.dart';
import 'package:adoptapp/widget/perfil_menu_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/page/mascota_register_page.dart';
import 'package:adoptapp/database.dart';
import 'package:adoptapp/entity/mascota.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PetGrid extends StatefulWidget {
  const PetGrid({Key? key}) : super(key: key);

  @override
  _PetGridState createState() => _PetGridState();
}

class _PetGridState extends State<PetGrid> {
  List<Mascota> mascotas = [];
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void updateMascotas() {
    getAllMascotas().then((mascotas) => {
          setState(() {
            this.mascotas = mascotas;
          })
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      updateMascotas();
      _selectedIndex = index;
    });
  }

  List<Widget> _list() {
    List<Widget> _widgetOptions = <Widget>[
      const Text(
        'SOON',
        style: optionStyle,
      ),
      ItemTile(context, mascotas),
      const Text(
        'SOON',
        style: optionStyle,
      ),
      const Text(
        'SOON',
        style: optionStyle,
      ),
    ];
    return _widgetOptions;
  }

  @override
  Widget build(BuildContext context) {
    updateMascotas();
    return Scaffold(
      appBar: AppBar(
          title: const Text("ADOPTAPP"),
          backgroundColor: Colors.orange,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => RegisterPet(),
                    ),
                  );
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
          automaticallyImplyLeading: false),
      body: Center(
        child: _list().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Salud',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house_siding),
            label: 'Refugios',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
      endDrawer: MenuPerfil(_auth.currentUser),
    );
  }
}

@override
Widget ItemTile(BuildContext context, List<Mascota> mascotas) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            FiltroPanel(),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: GridView.count(
              physics: const BouncingScrollPhysics(),
              childAspectRatio: 1 / 1.55,
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              children: mascotas
                  .map((item) => MascotaCard(
                        mascota: item,
                        index: null,
                      ))
                  .toList(),
            ))
          ],
        ),
      ),
    ),
  );
}
