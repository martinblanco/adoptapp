import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseMascotasService extends MascotasService {
  final _databaseReference = FirebaseDatabase.instance.ref();

  Future<String> _updatePetStatus(String petId, String estado) async {
    await _databaseReference
        .child('mascotas/')
        .child(petId)
        .update({'estado': estado});
    return petId;
  }

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
    return _updatePetStatus(petId, MascotaEstado.borrado);
  }

  @override
  Future<String> markPetAsAdopted(String petId) async {
    return _updatePetStatus(petId, MascotaEstado.adoptado);
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
        if (mascota.estado == MascotaEstado.enAdopcion) {
          mascotas.add(mascota);
        }
      }
    }
    return mascotas;
  }

  @override
  Future<Mascota?> getPetById(String petId) async {
    if (petId.isEmpty) {
      return null;
    }

    final DataSnapshot snapshot =
        await _databaseReference.child('mascotas/').child(petId).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final Mascota mascota = createMascota(snapshot.value);
    mascota.id = snapshot.key ?? petId;
    return mascota;
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
        if (mascota.user == uid && mascota.estado == MascotaEstado.enAdopcion) {
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
