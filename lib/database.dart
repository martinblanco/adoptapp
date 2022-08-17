import 'package:adoptapp/usuario.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:adoptapp/mascota.dart';

final databaseReference = FirebaseDatabase.instance.ref();

DatabaseReference saveMascota(Mascota mascota) {
  var id = databaseReference.child('mascotas/').push();
  id.set(mascota.toJson());
  return id;
}

DatabaseReference saveUsuario(Usuario usuario) {
  var id = databaseReference.child('usuarios/').push();
  id.set(usuario.toJson());
  return id;
}

Future<List<Mascota>> getAllMascotas() async {
  DataSnapshot dataSnapshot = await databaseReference.child('mascotas/').get();
  List<Mascota> mascotas = [];

  if (dataSnapshot.value != null) {
    for (DataSnapshot child in dataSnapshot.children) {
      Mascota mascota = createMascota(child.value);
      mascotas.add(mascota);
    }
  }
  return mascotas;
}
