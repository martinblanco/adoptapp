import 'package:flutter/material.dart';
import 'package:adoptapp/mascota.dart';

class ItemTile extends StatelessWidget {
  final int itemNo;

  final Mascota _mascota;

  const ItemTile(this.itemNo, this._mascota);

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.primaries[itemNo % Colors.primaries.length];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(8.0),
        child: Column(children: [
          Container(
            margin: EdgeInsets.all(2.0),
            child: ListTile(
              tileColor: Colors.deepOrange,
              onTap: () {},
              leading: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(
                        color: color.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.heart_broken,
                    size: 10,
                    color: Colors.white,
                  )),
              title: Text(
                'Product $itemNo',
                key: Key('text_$itemNo'),
              ),
            ),
          ),
          Container(
            color: color.withOpacity(0.3),
            child: Image.network(
                "https://ichef.bbci.co.uk/news/800/cpsprodpb/15665/production/_107435678_perro1.jpg",
                width: 100,
                height: 100,
                fit: BoxFit.cover),
          ),
          Column(
            children: [
              Container(
                child: Text(_mascota.nombre,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Ver")],
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }
}
