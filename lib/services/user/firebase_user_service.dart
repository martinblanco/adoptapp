import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseUserService extends UserService {
  final _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Future<Usuario> getUser(String uid) async {
    DataSnapshot dataSnapshot =
        await _databaseReference.child('usuarios/').equalTo(uid).get();
    return createUsuario(dataSnapshot.children);
  }

  @override
  Future<Usuario> addUser(Usuario newUser) async {
    await _databaseReference.child('usuarios/').push().set(newUser.toJson());
    return newUser;
  }

  @override
  Future<Usuario> updateUser(Usuario user) async {
    await _databaseReference
        .child('usuarios/')
        .child(user.id)
        .update(user.toJson());
    return user;
  }

  @override
  Future<String> deleteUser(String uid) async {
    await _databaseReference.child('usuarios/').child(uid).remove();
    return uid;
  }
}
