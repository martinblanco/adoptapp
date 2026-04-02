import 'package:adoptapp/screens/mascotas/mascota_filtros.dart';
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

class _MascotasGridState extends State<MascotasGrid>
    with WidgetsBindingObserver {
  Position? _currentUserPosition;
  late Future<void> _locationFuture;
  final MascotasService _mascotaService = services.get<MascotasService>();
  List<Mascota> displayedMascotas = [];
  FiltrosMascota _filtrosActuales = FiltrosMascota();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    displayedMascotas = widget.mascotas;
    _filtrosActuales = FiltrosMascota(
      perros: false,
      gatos: false,
      provincia: '',
    );
    _locationFuture = _loadCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadLocation();
    }
  }

  void _reloadLocation() {
    if (!mounted) return;

    setState(() {
      _locationFuture = _loadCurrentLocation();
    });
  }

  Future<void> _loadCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _currentUserPosition = null;
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _currentUserPosition = null;
      return;
    }

    try {
      _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (_) {
      _currentUserPosition = await Geolocator.getLastKnownPosition();
    }
  }

  bool _esPerro(String animal) {
    final a = animal.toLowerCase();
    return a.contains('perro') || a.contains('can');
  }

  bool _esGato(String animal) {
    final a = animal.toLowerCase();
    return a.contains('gato') || a.contains('fel');
  }

  void _filtrarMascotas() {
    displayedMascotas = widget.mascotas.where((mascota) {
      bool cumplePerrosGatos = true;

      if (_filtrosActuales.perros || _filtrosActuales.gatos) {
        cumplePerrosGatos = false;

        if (_filtrosActuales.perros && _esPerro(mascota.animal)) {
          cumplePerrosGatos = true;
        }
        if (_filtrosActuales.gatos && _esGato(mascota.animal)) {
          cumplePerrosGatos = true;
        }
      }

      // bool cumpleProvincia = true;
      // if (_filtrosActuales.provincia.isNotEmpty) {
      //   cumpleProvincia = mascota.provincia.toLowerCase() ==
      //       _filtrosActuales.provincia.toLowerCase();
      // }

      return cumplePerrosGatos;
    }).toList();
  }

  void _aplicarFiltros(FiltrosMascota filtros) {
    setState(() {
      _filtrosActuales = filtros;
      _filtrarMascotas();
    });
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
              FiltroPanel(
                onFilterChanged: (filtros) {
                  _aplicarFiltros(filtros);
                },
                filtrosActuales: _filtrosActuales,
              ),
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
                    future: _locationFuture,
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
                          itemCount: displayedMascotas.length,
                          itemBuilder: (BuildContext context, int index) =>
                              MascotaCard(
                                  mascota: displayedMascotas[index],
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
    final mascotas = await _mascotaService.getAllPets();
    if (!mounted) return;

    setState(() {
      widget.mascotas = mascotas;
      _filtrarMascotas();
      _locationFuture = _loadCurrentLocation();
    });
  }
}
