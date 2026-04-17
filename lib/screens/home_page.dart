import 'package:adoptapp/providers/mascotas_provider.dart';
import 'package:adoptapp/screens/publicacion_opciones_page.dart';
import 'package:adoptapp/widgets/mascota_grid_widget.dart';
import 'package:adoptapp/widgets/perfil_menu_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
            builder: (context) => Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    color: Colors.orange.shade800,
                    icon: const Icon(Icons.add_box_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const PublicacionOpcionesPage(),
                        ),
                      );
                    },
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                  IconButton(
                    color: Colors.orange.shade800,
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                ],
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Consumer<MascotasNotifier>(
        builder: (_, mascotasNotifier, __) => _selectedIndex != 2
            ? const Center(child: Text('SOON'))
            : _buildMascotasView(mascotasNotifier),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital), label: 'Veterinarias'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined), label: 'Tiendas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_drop_up_rounded, color: Colors.white),
              label: 'Mascotas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2), label: 'Servicios'),
          BottomNavigationBarItem(
              icon: Icon(Icons.house_siding), label: 'Refugios'),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orangeAccent[100],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(2);
        },
        tooltip: "Mascotas",
        child: const Icon(Icons.pets, color: Colors.orange),
        elevation: 4.0,
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawer: MenuPerfil(_auth.currentUser),
    );
  }

  Widget _buildMascotasView(MascotasNotifier mascotasNotifier) {
    if (mascotasNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mascotasNotifier.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${mascotasNotifier.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => mascotasNotifier.refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return MascotasGrid(mascotas: mascotasNotifier.mascotas);
  }

  void _onItemTapped(int index) {
    if (index == 2 && _selectedIndex != 2) {
      context.read<MascotasNotifier>().refresh();
    }
    setState(() => _selectedIndex = index);
  }
}
