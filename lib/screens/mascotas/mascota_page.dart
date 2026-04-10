import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/screens/profile_pege.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart'
    show PhotoManager, PermissionState, AssetEntity;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MascotaPage extends StatefulWidget {
  const MascotaPage({
    Key? key,
    required this.mascota,
  }) : super(key: key);

  final Mascota mascota;

  @override
  State<MascotaPage> createState() => _MascotaPageState();
}

class _MascotaPageState extends State<MascotaPage> {
  final PageController _pageController = PageController();
  final UserService _userService = services.get<UserService>();
  final GlobalKey _shareCardKey = GlobalKey();
  double currentPage = 0;
  bool _isLiked = false;
  bool _isFavoriteLoading = true;

  bool get _hasLocation =>
      widget.mascota.latitud != null && widget.mascota.longitud != null;

  LatLng get _petLocation =>
      LatLng(widget.mascota.latitud!, widget.mascota.longitud!);

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    if (!_hasLocation) {
      return;
    }

    final lat = widget.mascota.latitud!;
    final lng = widget.mascota.longitud!;
    final label = Uri.encodeComponent(widget.mascota.nombre);
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _loadFavoriteState() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.mascota.id.isEmpty) {
      if (mounted) {
        setState(() {
          _isLiked = false;
          _isFavoriteLoading = false;
        });
      }
      return;
    }

    try {
      final bool isFavorite =
          await _userService.isPetFavorite(user.uid, widget.mascota.id);
      if (mounted) {
        setState(() {
          _isLiked = isFavorite;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iniciá sesión para usar favoritos')),
      );
      return;
    }

    if (widget.mascota.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar este favorito')),
      );
      return;
    }

    final bool previousValue = _isLiked;
    setState(() {
      _isLiked = !previousValue;
    });

    try {
      if (previousValue) {
        await _userService.removeFavoritePet(user.uid, widget.mascota.id);
      } else {
        await _userService.addFavoritePet(user.uid, widget.mascota.id);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = previousValue;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  Uri _buildPetDeepLink() {
    final String petPath = '/mascota/${widget.mascota.id}';

    if (kIsWeb) {
      return Uri.parse('${Uri.base.origin}/#$petPath');
    }

    return Uri.parse('adoptapp://adoptapp$petPath');
  }

  Future<void> _sharePet() async {
    if (widget.mascota.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el enlace')),
      );
      return;
    }

    final Uri deepLink = _buildPetDeepLink();

    try {
      await Share.share(
        'Mira a ${widget.mascota.nombre} en AdoptApp\n$deepLink',
        subject: 'Adopta a ${widget.mascota.nombre}',
      );
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: deepLink.toString()));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No se pudo abrir compartir. Link copiado al portapapeles.'),
        ),
      );
    } on PlatformException {
      await Clipboard.setData(ClipboardData(text: deepLink.toString()));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo compartir. Link copiado al portapapeles.'),
        ),
      );
    }
  }

  String _buildShareFileName() {
    final DateTime now = DateTime.now();
    return 'mascota_${widget.mascota.id}_${now.millisecondsSinceEpoch}.png';
  }

  Future<Uint8List> _captureShareCard() async {
    await Future.delayed(const Duration(milliseconds: 80));

    final RenderObject? renderObject =
        _shareCardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception('No se pudo generar la imagen');
    }

    final ui.Image image = await renderObject.toImage(pixelRatio: 3);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('No se pudo convertir la imagen');
    }

    return byteData.buffer.asUint8List();
  }

  Future<File> _saveShareImageInDirectory(Directory directory) async {
    final Uint8List bytes = await _captureShareCard();
    final String filePath = '${directory.path}/${_buildShareFileName()}';
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _savePetCardImage() async {
    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      final bool hasPermission = permission == PermissionState.authorized ||
          permission == PermissionState.limited;
      if (!hasPermission) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de galeria denegado')),
        );
        return;
      }

      final Uint8List bytes = await _captureShareCard();
      final String imageName = _buildShareFileName().replaceAll('.png', '');
      final AssetEntity? result = await PhotoManager.editor.saveImage(
        bytes,
        title: imageName,
        filename: '$imageName.png',
      );

      final bool saved = result != null;

      if (!mounted) {
        return;
      }

      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen guardada en la galeria')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar en la galeria')),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar en la galeria')),
      );
    }
  }

  Future<void> _sharePetCardImage() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await _saveShareImageInDirectory(tempDir);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mira a ${widget.mascota.nombre} en AdoptApp',
        subject: 'Adopta a ${widget.mascota.nombre}',
      );
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir compartir imagen')),
      );
    } on PlatformException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo compartir la imagen')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar imagen')),
      );
    }
  }

  Future<void> _openShareCardActions() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RepaintBoundary(
                  key: _shareCardKey,
                  child: _buildSharePreviewCard(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _savePetCardImage();
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('G'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _sharePetCardImage();
                        },
                        icon: const Icon(Icons.ios_share),
                        label: const Text('C'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSharePreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                widget.mascota.fotoPerfil,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.orange[50],
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.pets,
                      color: Colors.orange,
                      size: 42,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mascota.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.mascota.edad} años  •  ${Mascota.getSexoString(widget.mascota.sexo)}  •  ${Mascota.getSizeIcon(widget.mascota.size)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.mascota.descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'AdoptApp',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.more_horiz,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 350,
              child: Stack(
                children: [
                  Hero(
                    tag: widget.mascota.fotoPerfil,
                    child: SizedBox(
                      height: 350,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.mascota.fotos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(widget.mascota.fotos[index]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DotsIndicator(
              dotsCount: 2,
              position: currentPage.toInt(),
              decorator: const DotsDecorator(
                color: Colors.grey,
                activeColor: Colors.orange,
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mascota.nombre,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _sharePet,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.share_outlined,
                                    size: 24,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _openShareCardActions,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 24,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap:
                                    _isFavoriteLoading ? null : _toggleFavorite,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isLiked
                                        ? Colors.red[400]
                                        : Colors.white,
                                  ),
                                  child: Icon(
                                    _isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 24,
                                    color: _isFavoriteLoading
                                        ? Colors.grey[500]
                                        : (_isLiked
                                            ? Colors.white
                                            : Colors.grey[400]),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        buildPetFeature(widget.mascota.edad + " Años", "Edad"),
                        buildPetFeature(
                            Mascota.getSizeIcon(widget.mascota.size), "Tamaño"),
                        buildPetFeature(
                            Mascota.getSexoString(widget.mascota.sexo), "Sexo"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Descripcion",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.mascota.descripcion +
                          widget.mascota.descripcion +
                          widget.mascota.descripcion +
                          widget.mascota.descripcion,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_hasLocation) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ubicación Aproximada',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: _openMap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 190,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                IgnorePointer(
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _petLocation,
                                      zoom: 14,
                                    ),
                                    mapToolbarEnabled: false,
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                    rotateGesturesEnabled: false,
                                    liteModeEnabled: true,
                                    circles: {
                                      Circle(
                                        circleId: const CircleId(
                                            'mascota_location_area'),
                                        center: _petLocation,
                                        radius: 350,
                                        fillColor: Colors.orange,
                                        strokeColor: Colors.orange,
                                        strokeWidth: 2,
                                      ),
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Abrir mapa',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16, left: 16, top: 16, bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(uid: widget.mascota.user),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/avatar.jpg',
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Subido por",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    widget.mascota.user,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Buenos aires, Argentina",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

buildPetFeature(String value, String feature) {
  return Expanded(
    child: Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Text(
            feature,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
