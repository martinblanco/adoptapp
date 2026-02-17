import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/widgets/mascota_card.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/entity/mascota.dart';

class MascotasGridd extends StatefulWidget {
  List<Mascota> mascotas;

  MascotasGridd({Key? key, required this.uid})
      : mascotas = [],
        super(key: key);

  final String uid;
  @override
  _MascotasGridState createState() => _MascotasGridState();
}

class _MascotasGridState extends State<MascotasGridd> {
  final MascotasService _mascotaService = services.get<MascotasService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.orange,
          color: Colors.white,
          onRefresh: _refresh,
          child: Scrollbar(
            child: FutureBuilder<void>(
              future: _refresh(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.stackTrace.toString());
                } else {
                  return GridView.builder(
                    key: const Key('MascotaGridView'),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          MediaQuery.of(context).size.height *
                          1.55,
                    ),
                    itemCount: widget.mascotas.length,
                    itemBuilder: (BuildContext context, int index) =>
                        MascotaCard(
                      mascota: widget.mascotas[index],
                      currentUserPosition: null,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    _mascotaService.getPetsByUser(widget.uid).then((mascotas) {
      setState(() {
        widget.mascotas = mascotas;
      });
    });
  }
}
