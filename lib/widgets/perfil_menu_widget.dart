import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/screens/login/user_login_page.dart';
import 'package:adoptapp/screens/profile_pege.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final user = FirebaseAuth.instance.currentUser;

class MenuPerfil extends StatefulWidget {
  const MenuPerfil(this.user, {Key? key}) : super(key: key);
  final User? user;
  @override
  _MenuPerfilState createState() => _MenuPerfilState();
}

class _MenuPerfilState extends State<MenuPerfil> {
  late final Usuario usuario;

  @override
  void initState() {
    super.initState();
    usuario = Usuario(user?.email ?? 'No email available',
        user?.displayName ?? 'Guest', "Usuario");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario.userName),
            accountEmail: Text(usuario.mail),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: user?.photoURL == null
                    ? Image.asset(
                        'assets/images/avatar.jpg',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      )
                    : Image.network(
                        user!.photoURL!,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.orange),
          ),
          _buildListTile(
            icon: Icons.person,
            title: 'Perfil',
            onTap: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ProfilePage(user!.uid),
                  ),
                );
              }
            },
          ),
          _buildListTile(
            icon: Icons.favorite,
            title: 'Favoritos',
            onTap: () {},
          ),
          const Divider(),
          _buildListTile(
            icon: Icons.settings,
            title: 'Configuracion',
            onTap: () {},
          ),
          const Divider(),
          _buildListTile(
            icon: Icons.exit_to_app,
            title: 'Exit',
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
