import 'package:flutter/material.dart';

class CombinedCard extends StatelessWidget {
  const CombinedCard({
    Key? key,
    required this.title,
    required this.contenido,
    this.isSingle = false,
  }) : super(key: key);

  final Widget title;
  final dynamic contenido;
  final bool isSingle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (isSingle)
                contenido
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: contenido,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
