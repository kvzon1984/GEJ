import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int age;
  final bool isNew;
  final String region;
  final String comuna;
  final String prayerRequest;
  final String observations;
  final String createdByUid;
  final String createdByEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.age,
    required this.isNew,
    required this.region,
    required this.comuna,
    required this.prayerRequest,
    required this.observations,
    required this.createdByUid,
    required this.createdByEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Helper para convertir timestamps, manejando valores null
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return Member(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      age: data['age'] ?? 0,
      isNew: data['isNew'] ?? false,
      region: data['region'] ?? '',
      comuna: data['comuna'] ?? '',
      prayerRequest: data['prayerRequest'] ?? '',
      observations: data['observations'] ?? '',
      createdByUid: data['createdByUid'] ?? '',
      createdByEmail: data['createdByEmail'] ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'age': age,
      'isNew': isNew,
      'region': region,
      'comuna': comuna,
      'prayerRequest': prayerRequest,
      'observations': observations,
      'createdByUid': createdByUid,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
