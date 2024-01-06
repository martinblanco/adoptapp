import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/widgets/mascota_grid_widget.dart';
import 'package:adoptapp/widgets/perfil_menu_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/screens/mascotas/mascota_register_page.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  static final routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MascotasService _mascotaService = services.get<MascotasService>();
  List<Mascota> mascotas = [];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const Text('SOON'),
      MascotasGrid(mascotas: mascotas),
      const Text('SOON'),
    ];

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
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Veterinarias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Masacotas',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(1);
        },
        tooltip: "Mascotas",
        child: Icon(Icons.pets, color: Colors.orange),
        elevation: 4.0,
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawer: MenuPerfil(_auth.currentUser),
    );
  }

  void updateMascotas() {
    _mascotaService.getAllPets().then((mascotas) => {
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
}
