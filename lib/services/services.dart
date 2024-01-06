import 'package:adoptapp/services/mascotas/firebase_mascotas_service.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/user/firebase_user_service.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:get_it/get_it.dart';

final services = GetIt.instance;

void initServices() {
  services
      .registerLazySingleton<MascotasService>(() => FirebaseMascotasService());
  services.registerLazySingleton<UserService>(() => FirebaseUserService());
}
