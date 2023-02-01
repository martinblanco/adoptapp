import 'package:adoptapp/page/mascota_page.dart';
import 'package:flutter/material.dart';
import '../entity/mascota.dart';

class MascotaCard extends StatefulWidget {
  final Mascota mascota;
  final int? index;

  const MascotaCard({Key? key, required this.mascota, required this.index})
      : super(key: key);

  @override
  _MascotaCardState createState() => _MascotaCardState();
}

class _MascotaCardState extends State<MascotaCard> {
  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.only(
            right: widget.index != null ? 16 : 0,
            left: widget.index == 0 ? 16 : 0,
            bottom: 16),
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: widget.mascota.fotoPerfil,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange,
                          width: 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(widget.mascota.fotoPerfil),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                            width: 1,
                          ),
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.all(1),
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.orange,
                                width: 1,
                              ),
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Icon(
                                (widget.mascota.sexo == Sexo.hembra.name
                                    ? Icons.female
                                    : widget.mascota.sexo == Sexo.macho.name
                                        ? Icons.male
                                        : Icons.pets),
                                color: Colors.white,
                                size: 16))),
                    Padding(
                        padding: const EdgeInsets.all(1),
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.orange,
                                width: 1,
                              ),
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              (widget.mascota.size == Size.chico.name
                                  ? "S"
                                  : widget.mascota.size == Size.mediano.name
                                      ? "M"
                                      : "L"),
                              style: const TextStyle(color: Colors.white),
                            ))),
                  ]),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.mascota.nombre,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        "CULO",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        "(2km)",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
