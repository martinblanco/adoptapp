import 'package:adoptapp/screens/mascotas/mascota_filtros.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/widgets/filtro_busqueda_widget.dart';
import 'package:adoptapp/widgets/mascota_card.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:geolocator/geolocator.dart';

enum _MascotaEstadoView { adopcion, perdido, encontrado }

class MascotasGrid extends StatefulWidget {
  final List<Mascota> mascotas;

  const MascotasGrid({Key? key, required this.mascotas}) : super(key: key);

  @override
  _MascotasGridState createState() => _MascotasGridState();
}

class _MascotasGridState extends State<MascotasGrid>
    with WidgetsBindingObserver {
  Position? _currentUserPosition;
  late Future<void> _locationFuture;
  final MascotasService _mascotaService = services.get<MascotasService>();
  List<Mascota> _allMascotas = [];
  List<Mascota> displayedMascotas = [];
  FiltrosMascota _filtrosActuales = FiltrosMascota();
  _MascotaEstadoView _selectedEstadoView = _MascotaEstadoView.adopcion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _allMascotas = List<Mascota>.from(widget.mascotas);
    _filtrosActuales = FiltrosMascota(
      perros: false,
      gatos: false,
      provincia: '',
    );
    _filtrarMascotas();
    _locationFuture = _loadCurrentLocation();
  }

  @override
  void didUpdateWidget(covariant MascotasGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mascotas != widget.mascotas) {
      _allMascotas = List<Mascota>.from(widget.mascotas);
      _filtrarMascotas();
    }
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

  bool _cumpleEstadoSeleccionado(Mascota mascota) {
    switch (_selectedEstadoView) {
      case _MascotaEstadoView.adopcion:
        return mascota.estado == MascotaEstado.enAdopcion;
      case _MascotaEstadoView.perdido:
        return mascota.estado == MascotaEstado.perdido;
      case _MascotaEstadoView.encontrado:
        return mascota.estado == MascotaEstado.encontrado;
    }
  }

  bool _cumpleSexoSeleccionado(Mascota mascota) {
    if (_filtrosActuales.sexo == Sexo.todos) {
      return true;
    }

    return mascota.sexo.toLowerCase() == _filtrosActuales.sexo.name;
  }

  void _filtrarMascotas() {
    displayedMascotas = _allMascotas.where((mascota) {
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

      return cumplePerrosGatos &&
          _cumpleEstadoSeleccionado(mascota) &&
          _cumpleSexoSeleccionado(mascota);
    }).toList();
  }

  void _aplicarFiltros(FiltrosMascota filtros) {
    setState(() {
      _filtrosActuales = filtros;
      _filtrarMascotas();
    });
  }

  void _cambiarEstado(_MascotaEstadoView estado) {
    setState(() {
      _selectedEstadoView = estado;
      _filtrarMascotas();
    });
  }

  Widget _buildEstadoSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SegmentedButton<_MascotaEstadoView>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          side: WidgetStateProperty.all(BorderSide.none),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFFFE7CC);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFD96B00);
            }
            return const Color(0xFF5B6472);
          }),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        segments: const [
          ButtonSegment<_MascotaEstadoView>(
            value: _MascotaEstadoView.perdido,
            icon: Icon(Icons.search_off_rounded, size: 16),
            label: Text('Perdidas'),
          ),
          ButtonSegment<_MascotaEstadoView>(
            value: _MascotaEstadoView.adopcion,
            icon: Icon(Icons.favorite_rounded, size: 16),
            label: Text('Adopción', style: TextStyle(fontSize: 16)),
          ),
          ButtonSegment<_MascotaEstadoView>(
            value: _MascotaEstadoView.encontrado,
            icon: Icon(Icons.pets_rounded, size: 16),
            label: Text('Encontradas'),
          ),
        ],
        selected: {_selectedEstadoView},
        onSelectionChanged: (selection) {
          _cambiarEstado(selection.first);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_selectedEstadoView) {
      case _MascotaEstadoView.adopcion:
        message = 'No hay mascotas en adopción con esos filtros.';
        break;
      case _MascotaEstadoView.perdido:
        message = 'No hay reportes de mascotas perdidas con esos filtros.';
        break;
      case _MascotaEstadoView.encontrado:
        message = 'No hay reportes de mascotas encontradas con esos filtros.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
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
              const SizedBox(height: 8),
              _buildEstadoSelector(),
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
                        if (displayedMascotas.isEmpty) {
                          return _buildEmptyState();
                        }

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
      _allMascotas = mascotas;
      _filtrarMascotas();
      _locationFuture = _loadCurrentLocation();
    });
  }
}
