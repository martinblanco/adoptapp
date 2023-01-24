import 'package:adoptapp/widget/filtroBusquedaPanel.dart';
import 'package:adoptapp/widget/mascotaCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/page/mascotaRegisterPage.dart';
import 'package:adoptapp/widget/perfilMenu.dart';
import 'package:adoptapp/database.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
      Text(
        'SOON',
        style: optionStyle,
      ),
      ItemTile(context, mascotas),
      Text(
        'SOON',
        style: optionStyle,
      ),
      Text(
        'SOON',
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
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.add_box_outlined),
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
                icon: Icon(Icons.menu),
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
      endDrawer: menuPerfil(_auth.currentUser),
    );
  }
}

@override
Widget ItemTile(BuildContext context, List<Mascota> mascotas) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            filtroPanel(),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: GridView.count(
              physics: BouncingScrollPhysics(),
              childAspectRatio: 1 / 1.55,
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              children: mascotas
                  .map((item) => mascotaCard(
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

RefreshController _refreshController = RefreshController(initialRefresh: false);
void _onRefresh() async {
  await Future.delayed(Duration(milliseconds: 1000));
  _refreshController.refreshCompleted();
}

void _onLoading() async {
  await Future.delayed(Duration(milliseconds: 1000));
  _refreshController.loadComplete();
}
