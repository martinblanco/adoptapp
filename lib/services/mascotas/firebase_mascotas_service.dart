import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseMascotasService extends MascotasService {
  final _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Future<Mascota> addPet(Mascota newPet) async {
    await _databaseReference.child('mascotas/').push().set(newPet.toJson());
    return newPet;
  }

  @override
  Future<Mascota> updatePet(Mascota editedPet) async {
    await _databaseReference
        .child('mascotas/')
        .child(editedPet.id)
        .update(editedPet.toJson());
    return editedPet;
  }

  @override
  Future<String> deletePet(String petId) async {
    await _databaseReference.child('mascotas/').child(petId).remove();
    return petId;
  }

  @override
  Future<List<Mascota>> getAllPets() async {
    DataSnapshot dataSnapshot =
        await _databaseReference.child('mascotas/').get();
    List<Mascota> mascotas = [];
    if (dataSnapshot.value != null) {
      for (DataSnapshot child in dataSnapshot.children) {
        Mascota mascota = createMascota(child.value);
        mascota.id = child.key ?? '';
        mascotas.add(mascota);
      }
    }
    return mascotas;
  }

  @override
  Future<List<Mascota>> getPetsByUser(String uid) async {
    DataSnapshot dataSnapshot =
        await _databaseReference.child('mascotas/').get();
    List<Mascota> mascotas = [];
    if (dataSnapshot.value != null) {
      for (DataSnapshot child in dataSnapshot.children) {
        Mascota mascota = createMascota(child.value);
        mascota.id = child.key ?? '';
        if (mascota.user == uid) {
          mascotas.add(mascota);
        }
      }
    }
    return mascotas;
  }

  @override
  Future<void> incrementInAppAdoptionsCounter() async {
    await _databaseReference
        .child('app_stats/adopciones_en_app')
        .runTransaction((Object? currentData) {
      if (currentData is num) {
        return Transaction.success(currentData.toInt() + 1);
      }

      if (currentData is String) {
        final parsedValue = int.tryParse(currentData) ?? 0;
        return Transaction.success(parsedValue + 1);
      }

      return Transaction.success(1);
    });
  }
}
