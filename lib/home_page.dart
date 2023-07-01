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
        items: <BottomNavigationBarItem>[
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
    ];
    return _widgetOptions;
  }

  @override
  Widget ItemTile(BuildContext context, List<Mascota> mascotas) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              FiltroPanel(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: Colors.orange,
                  color: Colors.white,
                  onRefresh: _refresh, // Replace with your refresh function
                  child: Scrollbar(
                    child: GridView.builder(
                      key: Key('MascotaGridView'),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        childAspectRatio: MediaQuery.of(context).size.width /
                            MediaQuery.of(context).size.height *
                            1.55,
                      ),
                      itemCount: mascotas.length,
                      itemBuilder: (BuildContext context, int index) =>
                          MascotaCard(mascota: mascotas[index]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 1));
  }
}
