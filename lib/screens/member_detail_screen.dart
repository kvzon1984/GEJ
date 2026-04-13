import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../services/firestore_service.dart';
import 'edit_member_screen.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;
  final String cityName;

  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.cityName,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Future<void> _deleteMember(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar a ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await FirestoreService().deleteMember(
          cityName: cityName,
          memberId: member.id,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Miembro eliminado')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Miembro'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditMemberScreen(
                    member: member,
                    cityName: cityName,
                  ),
                ),
              );
              // Si se actualizó, cerrar esta pantalla para refrescar
              if (result == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMember(context),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con nombre
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (member.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ Miembro Nuevo',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // Sección: Información de contacto
            _buildSection(
              context,
              title: 'Información de Contacto',
              icon: Icons.contact_phone,
              children: [
                _buildInfoRow(Icons.email, 'Email',
                    member.email.isEmpty ? 'No especificado' : member.email),
                _buildInfoRow(Icons.phone, 'Teléfono', member.phone),
                _buildInfoRow(Icons.cake, 'Edad', '${member.age} años'),
                _buildInfoRow(Icons.home, 'Dirección', member.address),
              ],
            ),

            // Sección: Ubicación
            _buildSection(
              context,
              title: 'Ubicación',
              icon: Icons.location_on,
              children: [
                _buildInfoRow(Icons.public, 'Ciudad', cityName),
                _buildInfoRow(Icons.place, 'Región', member.region),
                _buildInfoRow(Icons.location_city, 'Comuna', member.comuna),
              ],
            ),

            // Sección: Petición de oración
            if (member.prayerRequest.isNotEmpty)
              _buildSection(
                context,
                title: 'Petición de Oración',
                icon: Icons.favorite,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      member.prayerRequest,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),

            // Sección: Observaciones
            if (member.observations.isNotEmpty)
              _buildSection(
                context,
                title: 'Observaciones',
                icon: Icons.note,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      member.observations,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),

            // Sección: Información del sistema
            _buildSection(
              context,
              title: 'Información del Sistema',
              icon: Icons.info_outline,
              children: [
                _buildInfoRow(
                    Icons.person_outline,
                    'Agregado por',
                    member.createdByEmail.isEmpty
                        ? 'Usuario no registrado'
                        : member.createdByEmail),
                _buildInfoRow(Icons.calendar_today, 'Fecha de creación',
                    _formatDate(member.createdAt)),
                _buildInfoRow(Icons.update, 'Última actualización',
                    _formatDate(member.updatedAt)),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
