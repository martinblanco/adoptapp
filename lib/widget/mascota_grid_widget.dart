import 'package:adoptapp/widget/filtro_busqueda_widget.dart';
import 'package:adoptapp/widget/mascota_card.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:geolocator/geolocator.dart';

class MascotasGrid extends StatefulWidget {
  final List<Mascota> mascotas;

  const MascotasGrid({Key? key, required this.mascotas}) : super(key: key);

  @override
  _MascotasGridState createState() => _MascotasGridState();
}

class _MascotasGridState extends State<MascotasGrid> {
  Position? _currentUserPosition;

  Future _getTheDistance() async {
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              const FiltroPanel(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: Colors.orange,
                  color: Colors.white,
                  onRefresh: _refresh,
                  child: Scrollbar(
                      child: FutureBuilder<void>(
                    future: _getTheDistance(),
                    builder:
                        (BuildContext context, AsyncSnapshot<void> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error');
                      } else {
                        return GridView.builder(
                          key: Key('MascotaGridView'),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    MediaQuery.of(context).size.height *
                                    1.55,
                          ),
                          itemCount: widget.mascotas.length,
                          itemBuilder: (BuildContext context, int index) =>
                              MascotaCard(
                                  mascota: widget.mascotas[index],
                                  currentUserPosition: _currentUserPosition),
                        );
                      }
                    },
                  )),
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
