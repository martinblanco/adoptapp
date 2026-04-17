import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:adoptapp/widgets/mascota_grid_widget_perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _usuariosService = services.get<UserService>();
  Usuario? usuario;
  bool _isSavingProfile = false;
  bool _isUploadingPhoto = false;
  bool _isSavingSocialNetwork = false;
  bool _isSavingDonationMethod = false;
  Future<void> _showAddSocialNetworkDialog() async {
    if (usuario == null || _isSavingSocialNetwork || !_isProfileOwner) {
      return;
    }

    String selectedType = 'x';
    String socialUser = '';

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        String? validationError;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar red social'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: 'x', child: Text('X')),
                        DropdownMenuItem(
                            value: 'instagram', child: Text('Instagram')),
                        DropdownMenuItem(
                            value: 'facebook', child: Text('Facebook')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Red social',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      onChanged: (value) => socialUser = value,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        hintText: '@tuusuario',
                      ),
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        validationError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String normalizedUser =
                        _normalizedSocialUser(socialUser);

                    if (normalizedUser.isEmpty) {
                      setDialogState(() {
                        validationError = 'El usuario no puede estar vacío.';
                      });
                      return;
                    }

                    final bool alreadyExists = usuario!.redes.any((red) {
                      return red.tipo == selectedType &&
                          _normalizedSocialUser(red.usuario).toLowerCase() ==
                              normalizedUser.toLowerCase();
                    });

                    if (alreadyExists) {
                      setDialogState(() {
                        validationError =
                            'Esa red con ese usuario ya está agregada.';
                      });
                      return;
                    }

                    socialUser = normalizedUser;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || !mounted) {
      return;
    }

    final List<RedSocial> redesActualizadas = [
      ...usuario!.redes,
      RedSocial(tipo: selectedType, usuario: socialUser),
    ];

    setState(() {
      _isSavingSocialNetwork = true;
    });

    try {
      await _usuariosService.updateUserProfile(
        widget.uid,
        userName: usuario!.userName,
        description: usuario!.descripcion,
        redes: redesActualizadas,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        usuario!.redes = redesActualizadas;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Red social agregada')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la red social')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSocialNetwork = false;
        });
      }
    }
  }

  bool get _isProfileOwner =>
      FirebaseAuth.instance.currentUser?.uid == widget.uid;

  @override
  void initState() {
    super.initState();

    _usuariosService.getUser(widget.uid).then((user) {
      if (mounted) {
        setState(() {
          usuario = user;
        });
      }
    }).catchError((error) {});
  }

  Future<void> _showEditProfileDialog() async {
    if (usuario == null || _isSavingProfile || !_isProfileOwner) {
      return;
    }

    String editedName = usuario!.userName;
    String editedDescription = usuario!.descripcion;
    bool editedIsRefugio = usuario!.isRefugio;

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        String? validationError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar perfil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: editedName,
                      onChanged: (value) => editedName = value,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: editedDescription,
                      onChanged: (value) => editedDescription = value,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Refugio'),
                      value: editedIsRefugio,
                      onChanged: (value) {
                        setDialogState(() {
                          editedIsRefugio = value;
                        });
                      },
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        validationError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String newName = editedName.trim();
                    if (newName.isEmpty) {
                      setDialogState(() {
                        validationError = 'El nombre no puede estar vacío.';
                      });
                      return;
                    }

                    editedName = newName;
                    editedDescription = editedDescription.trim();
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || !mounted) {
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    try {
      await _usuariosService.updateUserProfile(
        widget.uid,
        userName: editedName,
        description: editedDescription,
        isRefugio: editedIsRefugio,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        usuario!
          ..userName = editedName
          ..descripcion = editedDescription
          ..isRefugio = editedIsRefugio;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el perfil')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    if (usuario == null || _isUploadingPhoto || !_isProfileOwner) {
      return;
    }

    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';
      final path =
          'usuarios/${widget.uid}/perfil_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$extension'),
      );
      final String downloadUrl = await ref.getDownloadURL();

      await _usuariosService.updateUserProfile(
        widget.uid,
        userName: usuario!.userName,
        description: usuario!.descripcion,
        photoUrl: downloadUrl,
      );

      await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

      if (!mounted) {
        return;
      }

      setState(() {
        usuario!.fotoPerfil = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la foto')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _showAddDonationMethodDialog() async {
    if (usuario == null || _isSavingDonationMethod || !_isProfileOwner) {
      return;
    }

    String selectedType = 'alias';
    String donationValue = '';

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        String? validationError;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar donación'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: 'alias', child: Text('Alias')),
                        DropdownMenuItem(value: 'cbu', child: Text('CBU')),
                        DropdownMenuItem(
                            value: 'cafecito', child: Text('Cafecito')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      onChanged: (value) => donationValue = value,
                      decoration: InputDecoration(
                        labelText: 'Dato',
                        hintText: selectedType == 'cafecito'
                            ? 'usuario o link de Cafecito'
                            : selectedType == 'cbu'
                                ? 'CBU'
                                : 'Alias',
                      ),
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        validationError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String normalizedValue =
                        _normalizedDonationValue(donationValue);

                    if (normalizedValue.isEmpty) {
                      setDialogState(() {
                        validationError =
                            'El dato de donación no puede estar vacío.';
                      });
                      return;
                    }

                    final bool alreadyExistsInDonations =
                        usuario!.donaciones.any((donacion) {
                      return donacion.tipo == selectedType &&
                          _normalizedDonationValue(donacion.usuario)
                                  .toLowerCase() ==
                              normalizedValue.toLowerCase();
                    });

                    if (alreadyExistsInDonations) {
                      setDialogState(() {
                        validationError =
                            'Ese método con ese dato ya está agregado.';
                      });
                      return;
                    }

                    donationValue = normalizedValue;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || !mounted) {
      return;
    }

    final List<RedSocial> donacionesActualizadas = [
      ...usuario!.donaciones,
      RedSocial(tipo: selectedType, usuario: donationValue),
    ];

    setState(() {
      _isSavingDonationMethod = true;
    });

    try {
      await _usuariosService.updateUserProfile(
        widget.uid,
        userName: usuario!.userName,
        description: usuario!.descripcion,
        donaciones: donacionesActualizadas,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        usuario!.donaciones = donacionesActualizadas;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donación agregada')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la donación')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDonationMethod = false;
        });
      }
    }
  }

  Future<void> _deleteDonationMethod(RedSocial red) async {
    if (usuario == null || _isSavingDonationMethod || !_isProfileOwner) {
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar donación'),
          content: Text(
              '¿Seguro que quieres eliminar ${_donationTitle(red.tipo)}: ${red.usuario}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final List<RedSocial> donacionesActualizadas = usuario!.donaciones
        .where((item) => !(item.tipo == red.tipo &&
            _normalizedDonationValue(item.usuario).toLowerCase() ==
                _normalizedDonationValue(red.usuario).toLowerCase()))
        .toList();

    setState(() {
      _isSavingDonationMethod = true;
    });

    try {
      await _usuariosService.updateUserProfile(
        widget.uid,
        userName: usuario!.userName,
        description: usuario!.descripcion,
        donaciones: donacionesActualizadas,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        usuario!.donaciones = donacionesActualizadas;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donación eliminada')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la donación')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDonationMethod = false;
        });
      }
    }
  }

  Future<void> _openDonationLinkIfPossible(RedSocial red) async {
    final String? urlStr = _buildDonationUrl(red);
    if (urlStr == null) {
      return;
    }
    final Uri url = Uri.parse(urlStr);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  String? _buildDonationUrl(RedSocial red) {
    if (red.tipo != 'cafecito') {
      return null;
    }

    final String value = _normalizedDonationValue(red.usuario);
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.contains('cafecito.app/')) {
      return 'https://$value';
    }
    return 'https://cafecito.app/$value';
  }

  String _normalizedDonationValue(String value) {
    return value.trim();
  }

  String _normalizedSocialUser(String user) {
    return user.trim().replaceFirst(RegExp(r'^@+'), '');
  }

  IconData _socialIcon(String type) {
    switch (type) {
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      default:
        return FontAwesomeIcons.xTwitter;
    }
  }

  String _socialTitle(String type) {
    switch (type) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      default:
        return 'X';
    }
  }

  Future<void> _openSocialNetwork(RedSocial red) async {
    final Uri url = Uri.parse(_buildSocialUrl(red));

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  String _buildSocialUrl(RedSocial red) {
    final String user = _normalizedSocialUser(red.usuario);
    switch (red.tipo) {
      case 'instagram':
        return 'https://instagram.com/$user';
      case 'facebook':
        return 'https://facebook.com/$user';
      default:
        return 'https://x.com/$user';
    }
  }

  Future<void> _deleteSocialNetwork(RedSocial red) async {
    if (usuario == null || _isSavingSocialNetwork || !_isProfileOwner) {
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar red social'),
          content: Text(
              '¿Seguro que quieres eliminar ${_socialTitle(red.tipo)} @${red.usuario}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final List<RedSocial> redesActualizadas = usuario!.redes
        .where((item) => !(item.tipo == red.tipo &&
            _normalizedSocialUser(item.usuario).toLowerCase() ==
                _normalizedSocialUser(red.usuario).toLowerCase()))
        .toList();

    setState(() {
      _isSavingSocialNetwork = true;
    });

    try {
      await _usuariosService.updateUserProfile(
        widget.uid,
        userName: usuario!.userName,
        description: usuario!.descripcion,
        redes: redesActualizadas,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        usuario!.redes = redesActualizadas;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Red social eliminada')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la red social')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSocialNetwork = false;
        });
      }
    }
  }

  Widget _donationIcon(String type) {
    switch (type) {
      case 'alias':
        return const Icon(Icons.alternate_email, size: 18);
      case 'cbu':
        return const Icon(Icons.account_balance, size: 18);
      case 'cafecito':
        return SvgPicture.asset(
          'assets/logos/cafecito_logo.svg',
          width: 18,
          height: 18,
        );
      default:
        return const Icon(Icons.payments_outlined, size: 18);
    }
  }

  String _donationTitle(String type) {
    switch (type) {
      case 'alias':
        return 'Alias';
      case 'cbu':
        return 'CBU';
      case 'cafecito':
        return 'Cafecito';
      default:
        return 'Donación';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          if (_isProfileOwner)
            _isSavingProfile
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar perfil',
                    onPressed: _showEditProfileDialog,
                  ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: _buildProfileImage(),
                            ),
                          ),
                          if (_isProfileOwner)
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Material(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _isUploadingPhoto
                                      ? null
                                      : _pickAndUploadProfilePhoto,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: _isUploadingPhoto
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 222,
                      height: 220,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            usuario!.userName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1F2937),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            usuario!.mail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                "About",
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                usuario!.descripcion.isEmpty
                    ? 'Sin descripción todavía.'
                    : usuario!.descripcion,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  const Text(
                    'Redes',
                    style: TextStyle(
                        color: Color(0xff242424),
                        fontSize: 28,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (_isProfileOwner)
                    _isSavingSocialNetwork
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            tooltip: 'Agregar red social',
                            onPressed: _showAddSocialNetworkDialog,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              if (usuario!.redes.isEmpty)
                const Text(
                  'Sin redes cargadas todavía.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                )
              else
                Column(
                  children: usuario!.redes.map((red) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => _openSocialNetwork(red),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xffFEF2F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(_socialIcon(red.tipo), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${_socialTitle(red.tipo)}: @${red.usuario}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              if (_isProfileOwner)
                                IconButton(
                                  tooltip: 'Eliminar red social',
                                  onPressed: _isSavingSocialNetwork
                                      ? null
                                      : () => _deleteSocialNetwork(red),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                ),
                              const Icon(Icons.open_in_new, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  const Text(
                    'Donaciones',
                    style: TextStyle(
                        color: Color(0xff242424),
                        fontSize: 28,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (_isProfileOwner)
                    _isSavingDonationMethod
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            tooltip: 'Agregar donación',
                            onPressed: _showAddDonationMethodDialog,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              if (usuario!.donaciones.isEmpty)
                const Text(
                  'Sin donaciones cargadas todavía.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                )
              else
                Column(
                  children: usuario!.donaciones.map((red) {
                    final bool hasExternalLink = red.tipo == 'cafecito';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: hasExternalLink
                            ? () => _openDonationLinkIfPossible(red)
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xffFEF2F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _donationIcon(red.tipo),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${_donationTitle(red.tipo)}: ${red.usuario}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              if (_isProfileOwner)
                                IconButton(
                                  tooltip: 'Eliminar donación',
                                  onPressed: _isSavingDonationMethod
                                      ? null
                                      : () => _deleteDonationMethod(red),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                ),
                              if (hasExternalLink)
                                const Icon(Icons.open_in_new, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                "En adopcion",
                style: TextStyle(
                    color: Color(0xff242424),
                    fontSize: 28,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                          color: const Color(0xffFBB97C),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: const Color(0xffFCCA9B),
                                  borderRadius: BorderRadius.circular(16)),
                              child:
                                  const Icon(FontAwesomeIcons.dog, size: 20.0)),
                          const SizedBox(
                            width: 16,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MascotasGridd(uid: widget.uid)),
                              );
                            },
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width / 2 - 130,
                              child: const Text(
                                "Perros",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                          color: const Color(0xffA5A5A5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: const Color(0xffBBBBBB),
                                  borderRadius: BorderRadius.circular(16)),
                              child:
                                  const Icon(FontAwesomeIcons.cat, size: 20.0)),
                          const SizedBox(
                            width: 16,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 130,
                            child: const Text(
                              "Gatos",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension on _ProfilePageState {
  Widget _buildProfileImage() {
    final String profileUrl = usuario?.fotoPerfil.trim() ?? '';
    final String authPhoto = FirebaseAuth.instance.currentUser?.photoURL ?? '';
    final String imageUrl = profileUrl.isNotEmpty ? profileUrl : authPhoto;

    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/avatar.jpg',
        fit: BoxFit.cover,
        width: 90,
        height: 90,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: 90,
      height: 90,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          'assets/images/avatar.jpg',
          fit: BoxFit.cover,
          width: 90,
          height: 90,
        );
      },
    );
  }
}
