import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/mascotas/mascota_page.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:flutter/material.dart';

class MascotaDeepLinkPage extends StatelessWidget {
  const MascotaDeepLinkPage({
    super.key,
    required this.petId,
  });

  final String petId;

  @override
  Widget build(BuildContext context) {
    final MascotasService mascotasService = services.get<MascotasService>();

    return FutureBuilder<Mascota?>(
      future: mascotasService.getPetById(petId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Mascota no encontrada'),
            ),
          );
        }

        return MascotaPage(mascota: snapshot.data!);
      },
    );
  }
}
