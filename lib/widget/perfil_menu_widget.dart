import 'package:adoptapp/entity/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../page/profile_pege.dart';

final user = FirebaseAuth.instance.currentUser;

class MenuPerfil extends StatefulWidget {
  MenuPerfil(this.currentUser, {Key? key}) : super(key: key);
  User? currentUser;
  @override
  _MenuPerfilState createState() => _MenuPerfilState();
}

class _MenuPerfilState extends State<MenuPerfil> {
  @override
  Widget build(BuildContext context) {
    Usuario usuario = Usuario("email?", "asd", "false");
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario.userName),
            accountEmail: Text(usuario.mail),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://ichef.bbci.co.uk/news/800/cpsprodpb/15665/production/_107435678_perro1.jpg',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.orange,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DoctorsInfo(user!.uid),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Policies'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
