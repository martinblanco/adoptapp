import 'package:adoptapp/entity/usuario.dart';

abstract class UserService {
  Future<Usuario> getUser(String uid);

  Future<Usuario> addUser(Usuario newUser);

  Future<Usuario> updateUser(Usuario editedUser);

  Future<String> deleteUser(String uid);
}
