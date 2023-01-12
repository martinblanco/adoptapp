// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:adoptapp/mascotaPage.dart';
import 'package:flutter/material.dart';
import '../entity/mascota.dart';

class mascotaCard extends StatefulWidget {
  Mascota mascota;

  mascotaCard({
    Key? key,
    required this.mascota,
  }) : super(key: key);

  @override
  _mascotaCardState createState() => new _mascotaCardState();
}

class _mascotaCardState extends State<mascotaCard> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              image: NetworkImage(widget.mascota.fotoPerfil),
              fit: BoxFit.cover,
              opacity: 0.7),
          boxShadow: [
            BoxShadow(color: Colors.black12, spreadRadius: 0.5),
          ],
          gradient: LinearGradient(
            colors: [Colors.black12, Colors.black87],
            begin: Alignment.center,
            stops: [0.4, 1],
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(60, -60),
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      size: 15,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SinglePage(mascota: widget.mascota),
                        ),
                      );
                    },
                  )),
            ),
            Positioned(
              right: 10,
              left: 10,
              bottom: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.mascota.nombre}, 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
