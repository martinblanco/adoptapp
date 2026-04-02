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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
      ),
    );
  }
}
