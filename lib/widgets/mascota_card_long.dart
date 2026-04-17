import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/mascotas/mascota_register_page.dart';
import 'package:adoptapp/screens/mascotas/mascota_page.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MascotaBanner extends StatefulWidget {
  final Mascota mascota;
  final Position? currentUserPosition;
  final Future<void> Function()? onEdit;
  final Future<void> Function(Mascota mascota)? onAdopted;
  final bool showEditButton;
  final bool showAdoptButton;

  const MascotaBanner(
      {Key? key,
      required this.mascota,
      required this.currentUserPosition,
      this.onEdit,
      this.onAdopted,
      this.showEditButton = true,
      this.showAdoptButton = true})
      : super(key: key);

  @override
  _MascotaBannerState createState() => _MascotaBannerState();
}

class _MascotaBannerState extends State<MascotaBanner> {
  final MascotasService _mascotaService = services.get<MascotasService>();
  bool _isAdoptionLoading = false;

  Future<void> _onFueAdoptadoPressed() async {
    if (_isAdoptionLoading) return;

    final bool? fueEnLaApp = await _showAdoptionSourceDialog();
    if (fueEnLaApp == null) return;

    if (widget.mascota.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar esta mascota')),
      );
      return;
    }

    setState(() {
      _isAdoptionLoading = true;
    });

    try {
      await _mascotaService.markPetAsAdopted(widget.mascota.id);

      if (fueEnLaApp) {
        await _mascotaService.incrementInAppAdoptionsCounter();
      }

      if (!mounted) return;

      if (widget.onAdopted != null) {
        await widget.onAdopted!(widget.mascota);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fueEnLaApp
                ? '${widget.mascota.nombre} marcado como adoptado en la app'
                : '${widget.mascota.nombre} marcado como adoptado por fuera',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al marcar la adopcion')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAdoptionLoading = false;
        });
      }
    }
  }

  Future<bool?> _showAdoptionSourceDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fue adoptado?'),
        content: const Text('Elegi como se concreto la adopcion'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Por fuera'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('En la app'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

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
                          if (widget.showEditButton)
                            Material(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () async {
                                  if (widget.onEdit != null) {
                                    await widget.onEdit!();
                                    return;
                                  }

                                  if (!mounted) return;
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterPet(
                                        mascotaToEdit: widget.mascota,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      _buildIcons(widget.mascota),
                      if (widget.showAdoptButton) ...[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF8A00), Color(0xFFFF5E62)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x4DFF8A00),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isAdoptionLoading
                                  ? null
                                  : _onFueAdoptadoPressed,
                              icon: _isAdoptionLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.volunteer_activism_rounded,
                                      size: 16),
                              label: const Text(
                                'Fue Adoptado!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                            ),
                          ),
                        ),
                      ],
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
