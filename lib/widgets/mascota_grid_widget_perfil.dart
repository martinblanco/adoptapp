import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:adoptapp/widgets/mascota_card.dart';
import 'package:flutter/material.dart';
import 'package:adoptapp/entity/mascota.dart';

class MascotasGridd extends StatefulWidget {
  const MascotasGridd({
    Key? key,
    required this.uid,
    this.showFavorites = false,
    this.title,
  }) : super(key: key);

  final String uid;
  final bool showFavorites;
  final String? title;

  @override
  _MascotasGridState createState() => _MascotasGridState();
}

class _MascotasGridState extends State<MascotasGridd> {
  final MascotasService _mascotaService = services.get<MascotasService>();
  final UserService _userService = services.get<UserService>();
  final List<Mascota> _mascotas = [];
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: Text(
          widget.title ?? (widget.showFavorites ? 'Favoritos' : 'En adopción'),
        ),
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
              future: _loadFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.stackTrace.toString());
                } else if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
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
                    itemCount: _mascotas.length,
                    itemBuilder: (BuildContext context, int index) =>
                        MascotaCard(
                      mascota: _mascotas[index],
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
    List<Mascota> mascotas;

    if (widget.showFavorites) {
      final Set<String> favoritePetIds =
          await _userService.getFavoritePetIds(widget.uid);
      final List<Mascota> allPets = await _mascotaService.getAllPets();
      mascotas = allPets
          .where((mascota) => favoritePetIds.contains(mascota.id))
          .toList();
    } else {
      mascotas = await _mascotaService.getPetsByUser(widget.uid);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _mascotas
        ..clear()
        ..addAll(mascotas);
    });
  }
}
