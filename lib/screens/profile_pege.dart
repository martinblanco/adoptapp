import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:adoptapp/widgets/mascota_grid_widget_perfil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _usuariosService = services.get<UserService>();
  Usuario? usuario;

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
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/avatar.jpg',
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          ),
                        ),
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
                            usuario!.mail,
                            style: const TextStyle(fontSize: 32),
                          ),
                          Text(
                            usuario!.userName,
                            style: const TextStyle(
                                fontSize: 19, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Row(
                            children: <Widget>[
                              IconTile(
                                  icon: FontAwesomeIcons.instagram,
                                  backColor: Color(0xffFEF2F0),
                                  size: 40.0),
                              IconTile(
                                  icon: FontAwesomeIcons.facebook,
                                  backColor: Color(0xffFEF2F0),
                                  size: 40.0),
                              IconTile(
                                  icon: FontAwesomeIcons.twitter,
                                  backColor: Color(0xffFEF2F0),
                                  size: 40.0),
                            ],
                          )
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
              const Text(
                "Dr. Stefeni Albert is a cardiologist in Nashville & affiliated with multiple hospitals in the  area.He received his medical degree from Duke University School of Medicine and has been in practice for more than 20 years. ",
                style: TextStyle(color: Colors.grey, fontSize: 16),
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

class IconTile extends StatelessWidget {
  final Color? backColor;
  final IconData? icon;

  final double size;

  const IconTile({Key? key, this.icon, this.backColor, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
            color: backColor, borderRadius: BorderRadius.circular(20)),
        child: Icon(icon, size: size / 2),
      ),
    );
  }
}
