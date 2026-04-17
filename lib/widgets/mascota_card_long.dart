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
  final Future<void> Function(Mascota mascota)? onStatusChanged;
  final bool showEditButton;
  final bool showPrimaryActionButton;
  final bool showDeleteButton;

  const MascotaBanner(
      {Key? key,
      required this.mascota,
      required this.currentUserPosition,
      this.onEdit,
      this.onStatusChanged,
      this.showEditButton = true,
      this.showPrimaryActionButton = true,
      this.showDeleteButton = true})
      : super(key: key);

  @override
  _MascotaBannerState createState() => _MascotaBannerState();
}

class _MascotaBannerState extends State<MascotaBanner> {
  final MascotasService _mascotaService = services.get<MascotasService>();
  bool _isAdoptionLoading = false;
  bool _isDeleteLoading = false;

  bool get _isAdoptionPost => widget.mascota.estado == MascotaEstado.enAdopcion;
  bool get _isLostPost => widget.mascota.estado == MascotaEstado.perdido;
  bool get _isFoundPost => widget.mascota.estado == MascotaEstado.encontrado;
  bool get _shouldShowPrimaryAction =>
      widget.showPrimaryActionButton &&
      (_isAdoptionPost || _isLostPost || _isFoundPost);

  String get _statusLabel {
    if (_isLostPost) return 'Perdido';
    if (_isFoundPost) return 'Encontrado';
    return 'En adopción';
  }

  List<Color> get _primaryActionColors {
    if (_isLostPost) {
      return const [Color(0xFFDC2626), Color(0xFFFB7185)];
    }
    if (_isFoundPost) {
      return const [Color(0xFF0F766E), Color(0xFF2DD4BF)];
    }
    return const [Color(0xFFFF8A00), Color(0xFFFF5E62)];
  }

  Color get _primaryActionShadowColor {
    if (_isLostPost) return const Color(0x4DDC2626);
    if (_isFoundPost) return const Color(0x4D0F766E);
    return const Color(0x4DFF8A00);
  }

  Color get _statusBadgeColor {
    if (_isLostPost) return const Color(0xFFDC2626);
    if (_isFoundPost) return const Color(0xFF0F766E);
    return Colors.orange;
  }

  Future<void> _notifyStatusChanged() async {
    if (widget.onStatusChanged != null) {
      await widget.onStatusChanged!(widget.mascota);
    }
  }

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

      await _notifyStatusChanged();

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

  Future<void> _onFueEncontradoPressed() async {
    if (_isAdoptionLoading) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isFoundPost ? 'Fue devuelto?' : 'Fue encontrado?'),
        content: const Text('Esta publicación dejará de mostrarse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true || widget.mascota.id.isEmpty) return;

    setState(() {
      _isAdoptionLoading = true;
    });

    try {
      await _mascotaService.markPetAsReturned(widget.mascota.id);

      if (!mounted) return;

      await _notifyStatusChanged();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFoundPost
                ? '${widget.mascota.nombre} marcado como devuelto'
                : '${widget.mascota.nombre} marcado como encontrado',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFoundPost
                ? 'Hubo un error al marcar como devuelto'
                : 'Hubo un error al marcar como encontrado',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAdoptionLoading = false;
        });
      }
    }
  }

  Future<void> _onDeletePressed() async {
    if (_isDeleteLoading || widget.mascota.id.isEmpty) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación?'),
        content: const Text('La publicación se ocultará de la app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleteLoading = true;
    });

    try {
      await _mascotaService.deletePet(widget.mascota.id);

      if (!mounted) return;

      await _notifyStatusChanged();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hubo un error al eliminar la publicación')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleteLoading = false;
        });
      }
    }
  }

  Future<void> _onPrimaryActionPressed() async {
    if (_isLostPost || _isFoundPost) {
      await _onFueEncontradoPressed();
      return;
    }

    await _onFueAdoptadoPressed();
  }

  String get _primaryActionLabel {
    if (_isLostPost) return 'Encontrado';
    if (_isFoundPost) return 'Devuelto';
    return 'Adoptado';
  }

  IconData get _primaryActionIcon {
    if (_isLostPost) return Icons.search;
    if (_isFoundPost) return Icons.keyboard_return_rounded;
    return Icons.volunteer_activism_rounded;
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
        constraints: const BoxConstraints(minHeight: 132),
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
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _badge(
                                  text: _statusLabel,
                                  backgroundColor: _statusBadgeColor,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.mascota.nombre.isEmpty
                                      ? 'Sin título'
                                      : widget.mascota.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.showEditButton)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                if (widget.showDeleteButton) ...[
                                  const SizedBox(width: 8),
                                  Material(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(999),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: _isDeleteLoading
                                          ? null
                                          : _onDeletePressed,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: _isDeleteLoading
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.red.shade400,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Colors.red.shade400,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                      _buildIcons(widget.mascota),
                      if (_shouldShowPrimaryAction) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _primaryActionColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryActionShadowColor,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isAdoptionLoading
                                  ? null
                                  : _onPrimaryActionPressed,
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
                                  : Icon(_primaryActionIcon, size: 16),
                              label: Text(
                                _primaryActionLabel,
                                style: const TextStyle(
                                  fontSize: 16,
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
                                    horizontal: 8, vertical: 2),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _badge({
    Widget? icon,
    String? text,
    double radius = 12,
    Color backgroundColor = Colors.orange,
  }) {
    if (text != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: radius,
      child: icon,
    );
  }

  Widget _buildIcons(Mascota mascota) {
    final sexString = Mascota.getSexoString(mascota.sexo);
    final sizeString = Mascota.getSizeIcon(mascota.size);
    final edadString =
        widget.mascota.edad.isEmpty ? '' : '${widget.mascota.edad} años';
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              if (sexString.isNotEmpty) _badge(text: sexString),
              if (sexString.isNotEmpty && edadString.isNotEmpty)
                const SizedBox(width: 4),
              if (edadString.isNotEmpty) _badge(text: edadString),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (sizeString.isNotEmpty) _badge(text: sizeString),
              if (sizeString.isNotEmpty && mascota.isCachorro)
                const SizedBox(width: 4),
              if (mascota.isCachorro) _badge(text: 'Cachorro')
            ],
          ),
        ],
      ),
    );
  }
}
