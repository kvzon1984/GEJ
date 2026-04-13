import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/member.dart';
import 'add_member_screen.dart';
import 'list_members_screen.dart';

class CityMenuScreen extends StatefulWidget {
  final String cityName;

  const CityMenuScreen({super.key, required this.cityName});

  @override
  State<CityMenuScreen> createState() => _CityMenuScreenState();
}

class _CityMenuScreenState extends State<CityMenuScreen> {
  bool _isExporting = false;

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      // Solicitar permisos para Android 13+
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isDenied) {
          await Permission.manageExternalStorage.request();
        }
      }

      // Obtener miembros de Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('cities')
          .doc(widget.cityName)
          .collection('members')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        throw 'No hay miembros para exportar';
      }

      final members =
          snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();

      // Crear archivo Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Miembros ${widget.cityName}'];
      excel.delete('Sheet1'); // Eliminar hoja por defecto

      // Agregar encabezados
      List<String> headers = [
        'Nombre',
        'Agregado Por',
        'Email',
        'Teléfono',
        'Edad',
        'Dirección',
        '¿Es Nuevo?',
        'Región',
        'Comuna',
        'Petición de Oración',
        'Observaciones',
        'Fecha de Creación',
        'Última Actualización',
      ];

      for (var i = 0; i < headers.length; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(headers[i]);
      }

      // Agregar datos
      for (var i = 0; i < members.length; i++) {
        final member = members[i];
        final rowIndex = i + 1;

        List<String> rowData = [
          member.name,
          member.createdByEmail.isEmpty
              ? 'Usuario no registrado'
              : member.createdByEmail,
          member.email.isEmpty ? 'No especificado' : member.email,
          member.phone,
          member.age.toString(),
          member.address,
          member.isNew ? 'Sí' : 'No',
          member.region,
          member.comuna,
          member.prayerRequest.isEmpty ? '-' : member.prayerRequest,
          member.observations.isEmpty ? '-' : member.observations,
          '${member.createdAt.day}/${member.createdAt.month}/${member.createdAt.year}',
          '${member.updatedAt.day}/${member.updatedAt.month}/${member.updatedAt.year}',
        ];

        for (var j = 0; j < rowData.length; j++) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: j, rowIndex: rowIndex))
              .value = TextCellValue(rowData[j]);
        }
      }

      // Guardar archivo
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName =
          'Miembros_${widget.cityName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory!.path}/$fileName';
      final fileBytes = excel.save();
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel guardado en: $filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 80,
                  color: Colors.deepPurple.shade700,
                ),
                const SizedBox(height: 32),
                Text(
                  '¿Qué desea hacer?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                ),
                const SizedBox(height: 48),
                _MenuButton(
                  icon: Icons.person_add,
                  label: 'Ingresar Nuevo',
                  color: Colors.green,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMemberScreen(cityName: widget.cityName),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _MenuButton(
                  icon: Icons.list_alt,
                  label: 'Listar Miembros',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListMembersScreen(cityName: widget.cityName),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _MenuButton(
                  icon: _isExporting
                      ? Icons.hourglass_empty
                      : Icons.file_download,
                  label: _isExporting ? 'Exportando...' : 'Exportar a Excel',
                  color: Colors.orange,
                  onPressed: _isExporting ? () {} : _exportToExcel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
