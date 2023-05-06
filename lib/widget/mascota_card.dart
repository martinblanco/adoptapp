import 'package:adoptapp/page/mascota_page.dart';
import 'package:flutter/material.dart';
import '../entity/mascota.dart';

class MascotaCard extends StatefulWidget {
  final Mascota mascota;

  const MascotaCard({Key? key, required this.mascota}) : super(key: key);

  @override
  _MascotaCardState createState() => _MascotaCardState();
}

class _MascotaCardState extends State<MascotaCard> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final String imageUrl = widget.mascota.fotoPerfil;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final scale = screenWidth / 375; // 375 is the reference screen width
    final baseFontSize = 16;
    final int scaledFontSize = (baseFontSize * scale).round();
    double width = MediaQuery.of(context).size.width;

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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
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
                    tag: imageUrl,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  buildHeartIcon(),
                ],
              ),
            ),
            const SizedBox(height: 5),
            _buildIcons(widget.mascota),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTextStyle(
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.mascota.nombre}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edad: ${widget.mascota.edad}'),
                    Text('Raza: ${widget.mascota.raza}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

// Método para construir el icono del corazón
Widget buildHeartIcon() {
  return Align(
    alignment: Alignment.topRight,
    child: Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        onPressed: () {
          // acción a realizar cuando se presiona el botón
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(1),
          primary: false ? Colors.orange : Colors.white,
          side: BorderSide(width: 1, color: Colors.orange),
        ),
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            size: 16,
            color: false ? Colors.white : Colors.red,
          ),
        ),
      ),
    ),
  );
}

_buildIcons(Mascota mascota) {
  final iconData = Mascota.getSexoIcon(mascota.sexo);
  final sizeText = Mascota.getSizeIcon(mascota.size);

  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _buildIcon(Icon(iconData, color: Colors.white, size: 16)),
        const SizedBox(width: 5),
        _buildIcon(Text(sizeText, style: const TextStyle(color: Colors.white)))
      ]));
}

Widget _buildIcon<T extends Widget>(T icon) {
  return CircleAvatar(
    backgroundColor: Colors.orange,
    radius: 12,
    child: icon,
  );
}
