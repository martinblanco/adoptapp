import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/mascotas/mascota_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MascotaCard extends StatefulWidget {
  final Mascota mascota;
  final Position? currentUserPosition;

  const MascotaCard(
      {Key? key, required this.mascota, required this.currentUserPosition})
      : super(key: key);

  @override
  _MascotaCardState createState() => _MascotaCardState();
}

class _MascotaCardState extends State<MascotaCard> {
  bool _isLiked = false;
  Future _getTheDistance(Mascota mascota) async {
    double? distanceImMeter = 0.0;
    double storelat = -34.5435;
    double storelng = -58.5165;

    if (widget.currentUserPosition != null) {
      distanceImMeter = Geolocator.distanceBetween(
        widget.currentUserPosition!.latitude,
        widget.currentUserPosition!.longitude,
        storelat,
        storelng,
      );
      mascota.distancia = (distanceImMeter.round().toInt() / 1000).round();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (widget.mascota.distancia == 0) {
      _getTheDistance(widget.mascota);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MascotaPage(mascota: widget.mascota)),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 10, // subir para ver mejor la sombra
        shadowColor: Colors.black38, // sombra más visible
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.none, // evitar que se recorte la sombra
        margin: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 8), // espacio para la sombra
        child: SizedBox(
          width: width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    _buildProfileImage(),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() => _isLiked = !_isLiked),
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.transparent, // sin fondo
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isLiked ? Colors.red : Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DefaultTextStyle(
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.mascota.nombre + " "),
                      Text("(${widget.mascota.distancia.toString()} km)",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              _buildIcons(widget.mascota),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // helpers
  Widget _buildProfileImage() {
    const String placeholderImagePathDog = 'assets/images/placeholderdog.jpg';
    const String placeholderImagePathCat = 'assets/images/placeholdercat.jpg';
    String placeholder = widget.mascota.animal.toLowerCase() == 'perro'
        ? placeholderImagePathDog
        : placeholderImagePathCat;
    final tag = 'mascota-${widget.mascota.id + widget.mascota.nombre}';
    final url = widget.mascota.fotoPerfil;
    return Hero(
      tag: tag,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.orange, width: 1.5), // borde naranja en la foto
        ),
        clipBehavior: Clip.hardEdge,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stack) {
                    return Image.asset(placeholder,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity);
                  },
                )
              : Image.asset(placeholder,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
        ),
      ),
    );
  }

  Widget _badge({Widget? icon, String? text, double radius = 12}) {
    if (text != null) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.orange),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.orange,
      radius: radius,
      child: icon,
    );
  }

  Widget _buildIcons(Mascota mascota) {
    //final iconData = Mascota.getAnimalIcon(mascota.animal);
    //final sizeText = Mascota.getSizeIcon(mascota.size);
    final sexString = Mascota.getSexoString(mascota.sexo);
    final sizeString = Mascota.getSizeIcon(mascota.size);
    final edadString = widget.mascota.edad + " años";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(text: sexString),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4)),
              _badge(text: edadString)
            ],
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
          Row(
            children: [
              _badge(text: sizeString),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4)),
              if (mascota.isCachorro) _badge(text: 'Cachorro')
            ],
          ),
        ],
      ),
    );
  }
}
