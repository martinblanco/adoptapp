import 'package:adoptapp/entity/usuario.dart';

abstract class UserService {
  Future<Usuario> getUser(String uid);

  Future<List<Usuario>> getAllUsers();

  Future<Usuario> addUser(Usuario newUser);

  Future<Usuario> updateUser(Usuario editedUser);

  Future<void> updateUserProfile(
    String uid, {
    required String userName,
    required String description,
    String? photoUrl,
    List<RedSocial>? redes,
    List<RedSocial>? donaciones,
    bool? isRefugio,
  });

  Future<String> deleteUser(String uid);

  Future<Set<String>> getFavoritePetIds(String uid);

  Future<bool> isPetFavorite(String uid, String petId);

  Future<void> addFavoritePet(String uid, String petId);

  Future<void> removeFavoritePet(String uid, String petId);
}
