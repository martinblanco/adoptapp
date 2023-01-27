// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:adoptapp/page/filtroBusquedaPage.dart';
import 'package:flutter/material.dart';

class filtroPanel extends StatefulWidget {
  @override
  _filtroPanelState createState() => new _filtroPanelState();
}

class _filtroPanelState extends State<filtroPanel> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.amber),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
              Colors.black.withOpacity(.4),
              Colors.black.withOpacity(.2),
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                Container(
                    height: 25,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 10),
                        ),
                        child: Icon(
                          Icons.list,
                          size: 15,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => FiltrosPage(),
                            ),
                          );
                        })),
                Container(
                    height: 25,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 10),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 15,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => FiltrosPage(),
                            ),
                          );
                        })),
                Container(
                    height: 25,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.black,
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 10),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 15,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => FiltrosPage(),
                            ),
                          );
                        }))
              ],
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
