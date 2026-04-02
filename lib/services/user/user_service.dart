import 'package:adoptapp/entity/usuario.dart';

abstract class UserService {
  Future<Usuario> getUser(String uid);

  Future<Usuario> addUser(Usuario newUser);

  Future<Usuario> updateUser(Usuario editedUser);

  Future<String> deleteUser(String uid);

  Future<Set<String>> getFavoritePetIds(String uid);

  Future<bool> isPetFavorite(String uid, String petId);

  Future<void> addFavoritePet(String uid, String petId);

  Future<void> removeFavoritePet(String uid, String petId);
}
