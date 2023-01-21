import 'package:adoptapp/widget/filtroBusquedaPanel.dart';
import 'package:adoptapp/widget/mascotaCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/page/mascotaRegisterPage.dart';
import 'package:adoptapp/widget/perfilMenu.dart';
import 'package:adoptapp/database.dart';
import 'package:adoptapp/entity/mascota.dart';
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
      ItemTile(context, mascotas),
      Text(
        'SOON',
        style: optionStyle,
      ),
      Text(
        'SOON',
        style: optionStyle,
      ),
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
      endDrawer: menuPerfil(),
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
                child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    header: ClassicHeader(),
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus? mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = Text("pull up load");
                        } else if (mode == LoadStatus.loading) {
                          body = CupertinoActivityIndicator();
                        } else if (mode == LoadStatus.failed) {
                          body = Text("Load Failed!Click retry!");
                        } else if (mode == LoadStatus.canLoading) {
                          body = Text("release to load more");
                        } else {
                          body = Text("No more Data");
                        }
                        return Container(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: mascotas
                          .map((item) => mascotaCard(mascota: item))
                          .toList(),
                    )))
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
