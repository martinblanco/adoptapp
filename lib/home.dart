import 'package:adoptapp/filters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/petRegister.dart';
import 'package:adoptapp/profileMenu.dart';
import 'package:adoptapp/database.dart';
import 'package:adoptapp/mascota.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'mascotaCard.dart';

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
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.amber),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient:
                        LinearGradient(begin: Alignment.bottomRight, colors: [
                      Colors.black.withOpacity(.4),
                      Colors.black.withOpacity(.2),
                    ])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        height: 25,
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.black,
                              backgroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 10),
                            ),
                            child: Text("Filtros"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      FiltrosPage(),
                                ),
                              );
                            })),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
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
                          .map((item) => Card(
                                color: Colors.transparent,
                                elevation: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          image: NetworkImage(item.fotoPerfil),
                                          fit: BoxFit.cover,
                                          opacity: 0.5),
                                      gradient: LinearGradient(
                                          begin: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withOpacity(1),
                                            Colors.black.withOpacity(1),
                                          ])),
                                  child: Transform.translate(
                                    offset: Offset(60, -60),
                                    child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 70, vertical: 70),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            color: Colors.white),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.favorite,
                                            size: 15,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    SinglePage(mascota: item),
                                              ),
                                            );
                                          },
                                        )),
                                  ),
                                ),
                              ))
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
