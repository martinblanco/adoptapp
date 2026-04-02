import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseUserService extends UserService {
  final _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Future<Usuario> getUser(String uid) async {
    DataSnapshot dataSnapshot =
        await _databaseReference.child('usuarios/$uid').get();
    if (!dataSnapshot.exists) {
      throw Exception('Usuario no encontrado');
    }
    return createUsuario(dataSnapshot.value as Map);
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

  @override
  Future<Set<String>> getFavoritePetIds(String uid) async {
    final DataSnapshot dataSnapshot =
        await _databaseReference.child('usuarios/$uid/favoritos').get();

    if (!dataSnapshot.exists || dataSnapshot.value == null) {
      return <String>{};
    }

    final dynamic rawValue = dataSnapshot.value;
    if (rawValue is Map) {
      return rawValue.keys.map((key) => key.toString()).toSet();
    }

    return <String>{};
  }

  @override
  Future<bool> isPetFavorite(String uid, String petId) async {
    if (petId.isEmpty) {
      return false;
    }

    final DataSnapshot dataSnapshot =
        await _databaseReference.child('usuarios/$uid/favoritos/$petId').get();
    return dataSnapshot.exists && dataSnapshot.value != null;
  }

  @override
  Future<void> addFavoritePet(String uid, String petId) async {
    if (petId.isEmpty) {
      return;
    }

    await _databaseReference.child('usuarios/$uid/favoritos/$petId').set(true);
  }

  @override
  Future<void> removeFavoritePet(String uid, String petId) async {
    if (petId.isEmpty) {
      return;
    }

    await _databaseReference.child('usuarios/$uid/favoritos/$petId').remove();
  }
}
