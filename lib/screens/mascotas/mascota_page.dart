import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/profile_pege.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MascotaPage extends StatefulWidget {
  const MascotaPage({
    Key? key,
    required this.mascota,
  }) : super(key: key);

  final Mascota mascota;

  @override
  State<MascotaPage> createState() => _MascotaPageState();
}

class _MascotaPageState extends State<MascotaPage> {
  final PageController _pageController = PageController();
  final UserService _userService = services.get<UserService>();
  double currentPage = 0;
  bool _isLiked = false;
  bool _isFavoriteLoading = true;

  bool get _hasLocation =>
      widget.mascota.latitud != null && widget.mascota.longitud != null;

  LatLng get _petLocation =>
      LatLng(widget.mascota.latitud!, widget.mascota.longitud!);

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    if (!_hasLocation) {
      return;
    }

    final lat = widget.mascota.latitud!;
    final lng = widget.mascota.longitud!;
    final label = Uri.encodeComponent(widget.mascota.nombre);
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _loadFavoriteState() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.mascota.id.isEmpty) {
      if (mounted) {
        setState(() {
          _isLiked = false;
          _isFavoriteLoading = false;
        });
      }
      return;
    }

    try {
      final bool isFavorite =
          await _userService.isPetFavorite(user.uid, widget.mascota.id);
      if (mounted) {
        setState(() {
          _isLiked = isFavorite;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iniciá sesión para usar favoritos')),
      );
      return;
    }

    if (widget.mascota.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar este favorito')),
      );
      return;
    }

    final bool previousValue = _isLiked;
    setState(() {
      _isLiked = !previousValue;
    });

    try {
      if (previousValue) {
        await _userService.removeFavoritePet(user.uid, widget.mascota.id);
      } else {
        await _userService.addFavoritePet(user.uid, widget.mascota.id);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = previousValue;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.more_horiz,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 350,
              child: Stack(
                children: [
                  Hero(
                    tag: widget.mascota.fotoPerfil,
                    child: SizedBox(
                      height: 350,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.mascota.fotos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(widget.mascota.fotos[index]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DotsIndicator(
              dotsCount: 2,
              position: currentPage.toInt(),
              decorator: const DotsDecorator(
                color: Colors.grey,
                activeColor: Colors.orange,
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mascota.nombre,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _isFavoriteLoading ? null : _toggleFavorite,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _isLiked ? Colors.red[400] : Colors.white,
                              ),
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 24,
                                color: _isFavoriteLoading
                                    ? Colors.grey[500]
                                    : (_isLiked
                                        ? Colors.white
                                        : Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        buildPetFeature(widget.mascota.edad + " Años", "Edad"),
                        buildPetFeature(
                            Mascota.getSizeIcon(widget.mascota.size), "Tamaño"),
                        buildPetFeature(
                            Mascota.getSexoString(widget.mascota.sexo), "Sexo"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Descripcion",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.mascota.descripcion +
                          widget.mascota.descripcion +
                          widget.mascota.descripcion +
                          widget.mascota.descripcion,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_hasLocation) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ubicación Aproximada',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: _openMap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 190,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                IgnorePointer(
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _petLocation,
                                      zoom: 14,
                                    ),
                                    mapToolbarEnabled: false,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                    rotateGesturesEnabled: false,
                                    liteModeEnabled: true,
                                    circles: {
                                      Circle(
                                        circleId: const CircleId(
                                            'mascota_location_area'),
                                        center: _petLocation,
                                        radius: 350,
                                        fillColor: Colors.orange,
                                        strokeColor: Colors.orange,
                                        strokeWidth: 2,
                                      ),
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Abrir mapa',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16, left: 16, top: 16, bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(uid: widget.mascota.user),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/avatar.jpg',
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Subido por",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    widget.mascota.user,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Buenos aires, Argentina",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

buildPetFeature(String value, String feature) {
  return Expanded(
    child: Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Text(
            feature,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
