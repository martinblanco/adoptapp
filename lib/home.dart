import 'package:adoptapp/filters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/petRegister.dart';
import 'package:adoptapp/profileMenu.dart';
import 'package:adoptapp/petItem.dart';
import 'package:adoptapp/database.dart';
import 'package:adoptapp/mascota.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PetGrid extends StatefulWidget {
  const PetGrid({Key? key}) : super(key: key);

  @override
  _PetGridState createState() => new _PetGridState();
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
      GridView.builder(
        itemCount: mascotas.length,
        itemBuilder: (context, index) =>
            ItemTile(index, mascotas.elementAt(index)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
        ),
      ),
      RegisterPet(),
      FiltrosPage(),
      Text(
        'Index 2: School',
        style: optionStyle,
      ),
      Text(
        'Index 3: Settings',
        style: optionStyle,
      ),
    ];
    return _widgetOptions;
  }

  @override
  Widget build(BuildContext context) {
    //getUsuario(_auth.currentUser!.uid);
    updateMascotas();
    return Scaffold(
        appBar: AppBar(
          title: Text("ADOPTAPP"),
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: _list().elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism),
              label: 'Veterinarias',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'Informacion',
              backgroundColor: Colors.purple,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.house_siding),
              label: 'Refugios',
              backgroundColor: Colors.pink,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        endDrawer: menuPerfil());
  }
}
