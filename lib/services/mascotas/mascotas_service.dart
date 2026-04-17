import 'package:adoptapp/entity/mascota.dart';

abstract class MascotasService {
  Future<Mascota> addPet(Mascota newPet);

  Future<Mascota> updatePet(Mascota editedPet);

  Future<String> deletePet(String petId);

  Future<String> markPetAsAdopted(String petId);

  Future<List<Mascota>> getAllPets();

  Future<Mascota?> getPetById(String petId);

  Future<List<Mascota>> getPetsByUser(String uid);

  Future<void> incrementInAppAdoptionsCounter();
}
