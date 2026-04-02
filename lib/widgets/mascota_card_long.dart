import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/mascotas/mascota_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MascotaBanner extends StatefulWidget {
  final Mascota mascota;
  final Position? currentUserPosition;

  const MascotaBanner(
      {Key? key, required this.mascota, required this.currentUserPosition})
      : super(key: key);

  @override
  _MascotaBannerState createState() => _MascotaBannerState();
}

class _MascotaBannerState extends State<MascotaBanner> {
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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              SizedBox(
                width: 138,
                child: _buildProfileImage(),
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF4E8), Color(0xFFFFFFFF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.mascota.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '${widget.mascota.distancia} km',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildIcons(widget.mascota),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // helpers
  Widget _buildProfileImage() {
    const String placeholderImagePathDog = 'assets/images/placeholderdog.jpg';
    const String placeholderImagePathCat = 'assets/images/placeholdercat.jpg';
    String placeholder = widget.mascota.animal.toLowerCase() == 'perro'
        ? placeholderImagePathDog
        : placeholderImagePathCat;
    final tag = 'mascota-${widget.mascota.id + widget.mascota.nombre}';
    final url = widget.mascota.fotoPerfil;
    return Hero(
      tag: tag,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 1.4),
        ),
        clipBehavior: Clip.hardEdge,
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.fitHeight,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stack) {
                  return Image.asset(placeholder,
                      fit: BoxFit.none,
                      width: double.infinity,
                      height: double.infinity);
                },
              )
            : Image.asset(placeholder,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity),
      ),
    );
  }

  Widget _badge({Widget? icon, String? text, double radius = 12}) {
    if (text != null) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.orange),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.orange,
      radius: radius,
      child: icon,
    );
  }

  Widget _buildIcons(Mascota mascota) {
    //final iconData = Mascota.getAnimalIcon(mascota.animal);
    //final sizeText = Mascota.getSizeIcon(mascota.size);
    final sexString = Mascota.getSexoString(mascota.sexo);
    final sizeString = Mascota.getSizeIcon(mascota.size);
    final edadString = widget.mascota.edad + " años";
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _badge(text: sexString),
              const SizedBox(width: 4),
              _badge(text: edadString)
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _badge(text: sizeString),
              const SizedBox(width: 4),
              if (mascota.isCachorro) _badge(text: 'Cachorro')
            ],
          ),
        ],
      ),
    );
  }
}
