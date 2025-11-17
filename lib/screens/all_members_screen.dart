import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gej_app/models/member.dart';
import 'package:gej_app/screens/member_detail_screen.dart';
import 'package:rxdart/rxdart.dart';

class AllMembersScreen extends StatelessWidget {
  const AllMembersScreen({super.key});

  Stream<List<Map<String, dynamic>>> _getAllMembers() {
    final cities = ['Santiago', 'Valdivia', 'Villarrica', 'Paine'];
    final firestore = FirebaseFirestore.instance;

    // Combinar streams de todas las ciudades en tiempo real
    final streams = cities
        .map((city) => firestore
            .collection('cities')
            .doc(city)
            .collection('members')
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => {
                      'cityName': city,
                      'member': Member.fromFirestore(doc),
                    })
                .toList()))
        .toList();

    // Combinar todos los streams y aplanar la lista
    return Rx.combineLatest(streams, (values) {
      final allMembers = values.expand((list) => list).toList();
      // Ordenar por fecha de creación descendente
      allMembers.sort((a, b) => (b['member'] as Member)
          .createdAt
          .compareTo((a['member'] as Member).createdAt));
      return allMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Miembros'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getAllMembers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar los miembros',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final membersData = snapshot.data ?? [];

            if (membersData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay miembros registrados',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Contador de miembros
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'Total: ${membersData.length} miembros',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de miembros
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: membersData.length,
                    itemBuilder: (context, index) {
                      final data = membersData[index];
                      final member = data['member'] as Member;
                      final cityName = data['cityName'] as String;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade700,
                            child: Text(
                              member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCityColor(cityName),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  cityName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              if (member.email.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        member.email,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    member.phone,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              if (member.isNew) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        '✓ Nuevo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MemberDetailScreen(
                                  member: member,
                                  cityName: cityName,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getCityColor(String cityName) {
    switch (cityName) {
      case 'Santiago':
        return Colors.blue;
      case 'Valdivia':
        return Colors.green;
      case 'Villarrica':
        return Colors.orange;
      case 'Paine':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
