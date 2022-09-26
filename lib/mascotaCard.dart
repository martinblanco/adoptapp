import 'dart:convert';

import 'package:adoptapp/mascota.dart';
import 'package:flutter/material.dart';

class SinglePage extends StatefulWidget {
  SinglePage({
    Key? key,
    required this.mascota,
  }) : super(key: key);

  Mascota mascota;

  @override
  State<SinglePage> createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: FutureBuilder(builder: (context, snapshot) {
      return Stack(
        children: [
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Image.network(
                "https://ichef.bbci.co.uk/news/800/cpsprodpb/15665/production/_107435678_perro1.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 30.0,
            left: 25.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              child: Column(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            left: 0.0,
            right: 0.0,
            bottom: MediaQuery.of(context).size.height * 0.14,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hace 2 Dias",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.mascota.nombre,
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          widget.mascota.sexo,
                          style: TextStyle(
                            fontSize: 21.0,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 40.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              widget.mascota.size,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          height: 40.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              "Cachorro",
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          height: 40.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              "Lindo",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Algo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Text(
                      """Dual Motor.""",
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Descripcion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: Text(
                      "DESCRIPCION HARDCODE",
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.295,
            right: 30.0,
            child: Container(
              width: 70.0,
              height: 70.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(1, 1),
                    ),
                  ]),
              child: const Icon(
                Icons.favorite,
                size: 25.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }));
  }
}
