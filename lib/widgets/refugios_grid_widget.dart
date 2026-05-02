import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/screens/profile_pege.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RefugiosGrid extends StatefulWidget {
  const RefugiosGrid({Key? key, required this.refugios}) : super(key: key);

  final List<Usuario> refugios;

  @override
  State<RefugiosGrid> createState() => _RefugiosGridState();
}

class _RefugiosGridState extends State<RefugiosGrid> {
  final TextEditingController _searchController = TextEditingController();
  List<Usuario> _allRefugios = <Usuario>[];
  List<Usuario> _displayedRefugios = <Usuario>[];
  bool _soloConDonaciones = false;
  Position? _currentUserPosition;
  late Future<void> _locationFuture;

  @override
  void initState() {
    super.initState();
    _allRefugios = List<Usuario>.from(widget.refugios);
    _filtrarRefugios();
    _locationFuture = _loadCurrentLocation();
  }

  @override
  void didUpdateWidget(covariant RefugiosGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refugios != widget.refugios) {
      _allRefugios = List<Usuario>.from(widget.refugios);
      _filtrarRefugios();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarRefugios() {
    final String query = _searchController.text.trim().toLowerCase();

    setState(() {
      _displayedRefugios = _allRefugios.where((refugio) {
        final String nombre = refugio.userName.trim().toLowerCase();
        final String descripcion = refugio.descripcion.trim().toLowerCase();
        final bool coincideTexto = query.isEmpty ||
            nombre.contains(query) ||
            descripcion.contains(query);
        final bool coincideDonaciones =
            !_soloConDonaciones || refugio.donaciones.isNotEmpty;

        return coincideTexto && coincideDonaciones;
      }).toList();
    });
  }

  void _onSearchChanged(String _) {
    _filtrarRefugios();
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

  double _distanceKmForRefugio(Usuario refugio) {
    final double? shelterLat = refugio.latitud;
    final double? shelterLng = refugio.longitud;
    if (_currentUserPosition == null ||
        shelterLat == null ||
        shelterLng == null) {
      return 0;
    }

    final distanceMeters = Geolocator.distanceBetween(
      _currentUserPosition!.latitude,
      _currentUserPosition!.longitude,
      shelterLat,
      shelterLng,
    );

    return distanceMeters / 1000;
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm <= 0) {
      return '0 km';
    }

    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }

    return '${distanceKm.round()} km';
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar refugio por nombre o descripción',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _filtrarRefugios();
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              selected: _soloConDonaciones,
              onSelected: (selected) {
                setState(() {
                  _soloConDonaciones = selected;
                });
                _filtrarRefugios();
              },
              showCheckmark: false,
              avatar: Icon(
                Icons.volunteer_activism_rounded,
                size: 16,
                color: _soloConDonaciones
                    ? const Color(0xFF8A4A00)
                    : const Color(0xFF5F6B7A),
              ),
              label: const Text('Solo con datos de donación'),
              backgroundColor: const Color(0xFFF5F7FA),
              selectedColor: const Color(0xFFFFE7CC),
              side: BorderSide(
                color: _soloConDonaciones
                    ? const Color(0xFFF4B36A)
                    : const Color(0xFFD7DEE7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No encontramos refugios con esos filtros.',
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

  int _crossAxisCount(double width) {
    if (width >= 1200) return 3;
    if (width >= 800) return 2;
    if (width >= 560) return 2;
    return 1;
  }

  Widget _buildCard(Usuario refugio) {
    final bool hasPhoto = refugio.fotoPerfil.trim().isNotEmpty;
    final bool hasDescription = refugio.descripcion.trim().isNotEmpty;
    final String distanceLabel =
        _formatDistance(_distanceKmForRefugio(refugio));

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: refugio.id),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF0F3F7)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 360;
            final double imageWidth = compact
                ? constraints.maxWidth * 0.34
                : constraints.maxWidth * 0.42;

            return Row(
              children: [
                SizedBox(
                  width: imageWidth,
                  height: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18),
                    ),
                    child: hasPhoto
                        ? Image.network(
                            refugio.fotoPerfil,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFFFF1DF),
                              child: const Icon(
                                Icons.house_siding,
                                color: Color(0xFFD96B00),
                                size: 34,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFFFF1DF),
                            child: const Icon(
                              Icons.house_siding,
                              color: Color(0xFFD96B00),
                              size: 34,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          refugio.userName.trim().isEmpty
                              ? 'Refugio'
                              : refugio.userName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 14 : 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF232B36),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            hasDescription
                                ? refugio.descripcion
                                : 'Sin descripción cargada.',
                            maxLines: compact ? 3 : 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 12 : 13,
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.pets_rounded,
                              size: 16,
                              color: Color(0xFF5F6B7A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${refugio.mascotas.length} mascotas',
                              style: TextStyle(
                                fontSize: compact ? 11 : 12,
                                color: const Color(0xFF5F6B7A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.near_me_rounded,
                              size: 15,
                              color: Color(0xFF5F6B7A),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              distanceLabel,
                              style: TextStyle(
                                fontSize: compact ? 11 : 12,
                                color: const Color(0xFF5F6B7A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (refugio.donaciones.isNotEmpty)
                              const Icon(
                                Icons.volunteer_activism_rounded,
                                size: 17,
                                color: Color(0xFFD96B00),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int itemsCount = _displayedRefugios.length;

    return FutureBuilder<void>(
      future: _locationFuture,
      builder: (context, _) => Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: itemsCount == 0
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final int count = _crossAxisCount(constraints.maxWidth);

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
                        itemCount: itemsCount,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: count == 1 ? 2.35 : 1.35,
                        ),
                        itemBuilder: (context, index) =>
                            _buildCard(_displayedRefugios[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
