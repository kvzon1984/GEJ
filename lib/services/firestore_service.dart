import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Agregar un nuevo miembro
  Future<void> addMember({
    required String cityName,
    required String name,
    required String email,
    required String phone,
    required String address,
    required bool isNew,
    required String region,
    required String comuna,
    required String prayerRequest,
    required String observations,
  }) async {
    try {
      await _db.collection('cities').doc(cityName).collection('members').add({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'isNew': isNew,
        'region': region,
        'comuna': comuna,
        'prayerRequest': prayerRequest,
        'observations': observations,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error al agregar miembro: $e';
    }
  }

  // Obtener miembros de una ciudad
  Stream<QuerySnapshot> getMembers(String cityName) {
    return _db
        .collection('cities')
        .doc(cityName)
        .collection('members')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Actualizar un miembro
  Future<void> updateMember({
    required String cityName,
    required String memberId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required bool isNew,
    required String region,
    required String comuna,
    required String prayerRequest,
    required String observations,
  }) async {
    try {
      await _db
          .collection('cities')
          .doc(cityName)
          .collection('members')
          .doc(memberId)
          .update({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'isNew': isNew,
        'region': region,
        'comuna': comuna,
        'prayerRequest': prayerRequest,
        'observations': observations,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error al actualizar miembro: $e';
    }
  }

  // Eliminar un miembro
  Future<void> deleteMember({
    required String cityName,
    required String memberId,
  }) async {
    try {
      await _db
          .collection('cities')
          .doc(cityName)
          .collection('members')
          .doc(memberId)
          .delete();
    } catch (e) {
      throw 'Error al eliminar miembro: $e';
    }
  }

  // Obtener un miembro específico
  Future<DocumentSnapshot> getMember({
    required String cityName,
    required String memberId,
  }) async {
    return await _db
        .collection('cities')
        .doc(cityName)
        .collection('members')
        .doc(memberId)
        .get();
  }

  // Buscar miembros por nombre
  Future<QuerySnapshot> searchMembers(
      String cityName, String searchTerm) async {
    return await _db
        .collection('cities')
        .doc(cityName)
        .collection('members')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + 'z')
        .get();
  }
}
