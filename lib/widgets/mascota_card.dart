import 'package:adoptapp/screens/mascotas/mascota_page.dart';
import 'package:flutter/material.dart';
import '../entity/mascota.dart';
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
    //final mediaQuery = MediaQuery.of(context);
    const String placeholderImagePath = 'assets/images/placeholder.png';
    //final screenWidth = mediaQuery.size.width;
    //final screenHeight = mediaQuery.size.height;
    //final scale = screenWidth / 375; // 375 is the reference screen width
    //const baseFontSize = 16;
    //final int scaledFontSize = (baseFontSize * scale).round();
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          border: Border.all(
            color: Colors.orange,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.only(right: 0, left: 0, bottom: 16),
        width: width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: widget.mascota.fotoPerfil,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: (widget.mascota.fotoPerfil.isNotEmpty)
                          ? Image.network(
                              widget.mascota.fotoPerfil,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.asset(
                              placeholderImagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(
                                side: BorderSide(
                                    color: Color.fromRGBO(255, 255, 255, 0.3),
                                    width: 1)),
                            padding: const EdgeInsets.all(1),
                            fixedSize: const Size(30, 30),
                            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 22,
                              color: Colors.orange,
                            ),
                            Icon(
                              Icons.favorite,
                              size: 15,
                              color: _isLiked ? Colors.orange : Colors.white,
                            ),
                          ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mascota.nombre + ", " + widget.mascota.edad),
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
    );
  }
}

_buildIcons(Mascota mascota) {
  final iconData = Mascota.getSexoIcon(mascota.sexo);
  final sizeText = Mascota.getSizeIcon(mascota.size);

  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        mascota.isCachorro ? _buildText() : const SizedBox.shrink(),
        const SizedBox(width: 5),
        _buildIcon(Icon(iconData, color: Colors.white, size: 16)),
        const SizedBox(width: 5),
        _buildIcon(Text(sizeText, style: const TextStyle(color: Colors.white))),
      ]));
}

Widget _buildIcon<T extends Widget>(T icon) {
  return CircleAvatar(
    backgroundColor: Colors.orange,
    radius: 12,
    child: icon,
  );
}

Widget _buildText<T extends Widget>() {
  return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.orange),
      child: const Padding(
          padding: EdgeInsets.all(2.0),
          child: Text("Cachorro", style: TextStyle(color: Colors.white))));
}
