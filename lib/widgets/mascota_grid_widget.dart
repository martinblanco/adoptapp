import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/widgets/filtro_busqueda_widget.dart';
import 'package:adoptapp/widgets/mascota_card.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:geolocator/geolocator.dart';

class MascotasGrid extends StatefulWidget {
  List<Mascota> mascotas;

  MascotasGrid({Key? key, required this.mascotas}) : super(key: key);

  @override
  _MascotasGridState createState() => _MascotasGridState();
}

class _MascotasGridState extends State<MascotasGrid> {
  Position? _currentUserPosition;
  final MascotasService _mascotaService = services.get<MascotasService>();
  Future _getTheDistance() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (enabled) {
      try {
        _currentUserPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
      } catch (e) {
        _currentUserPosition = null;
      }
    } else {
      //LocationPermission permission = await Geolocator.checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                        return Text(snapshot.stackTrace.toString());
                      } else {
                        return GridView.builder(
                          key: const Key('MascotaGridView'),
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

  Future<void> _refresh() async {
    _mascotaService.getAllPets().then((mascotas) => {
          setState(() {
            widget.mascotas = mascotas;
          })
        });
  }
}
