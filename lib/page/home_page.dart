import 'package:adoptapp/widget/mascota_grid_widget.dart';
import 'package:adoptapp/widget/perfil_menu_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/page/mascota_register_page.dart';
import 'package:adoptapp/database.dart';
import 'package:adoptapp/entity/mascota.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Mascota> mascotas = [];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    updateMascotas();
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'ADOPTAPP',
            style: TextStyle(
              color: Colors.orange,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            Builder(
              builder: (context) => IconButton(
                color: Colors.orange,
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
                color: Colors.orange,
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
            icon: Icon(Icons.local_hospital),
            label: 'Salud',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Refugios',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      endDrawer: MenuPerfil(_auth.currentUser),
    );
  }

  void updateMascotas() {
    getAllMascotas().then((mascotas) => {
          setState(() {
            this.mascotas = mascotas;
          })
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        updateMascotas();
      }
      _selectedIndex = index;
    });
  }

  List<Widget> _list() {
    List<Widget> _widgetOptions = <Widget>[
      const Text('SOON'),
      MascotasGrid(mascotas: mascotas),
      const Text('SOON'),
    ];
    return _widgetOptions;
  }
}
