// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:adoptapp/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final user = FirebaseAuth.instance.currentUser;

class menuPerfil extends StatefulWidget {
  @override
  _menuPerfilState createState() => new _menuPerfilState();
}

class _menuPerfilState extends State<menuPerfil> {
  getUser() {
    if (user != null) {
      final name = user!.displayName;
      final email = user!.email;
      final photoUrl = user!.photoURL;
      final emailVerified = user!.emailVerified;
      final uid = user!.uid;
      Usuario usuario = new Usuario(email!, name!, "false");
      return usuario;
    }
  }

  @override
  Widget build(BuildContext context) {
    Usuario usuario = getUser();
    return new Drawer(
      child: ListView(
        // Remove padding
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
            decoration: BoxDecoration(
              color: Colors.orange,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favorites'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.messenger_sharp),
            title: Text('Chats'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Request'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Policies'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Exit'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => null,
          ),
        ],
      ),
    );
  }
}
