import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddMemberScreen extends StatefulWidget {
  final String cityName;

  const AddMemberScreen({super.key, required this.cityName});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _prayerRequestController = TextEditingController();
  final _observationsController = TextEditingController();
  final _comunaController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _isNew = false;
  String _selectedRegion = '';
  String? _selectedComuna;
  bool _showComunaField = false;

  // Listas de comunas por ciudad
  final Map<String, List<String>> _comunasByCiudad = {
    'Santiago': [
      'Santiago Centro',
      'Providencia',
      'Las Condes',
      'Vitacura',
      'Lo Barnechea',
      'Ñuñoa',
      'La Reina',
      'Macul',
      'Peñalolén',
      'La Florida',
      'Maipú',
      'Pudahuel',
      'Cerrillos',
      'Estación Central',
      'Pedro Aguirre Cerda',
      'San Miguel',
      'La Cisterna',
      'San Ramón',
      'La Granja',
      'El Bosque',
      'La Pintana',
      'San Bernardo',
      'Puente Alto',
      'Quilicura',
      'Renca',
      'Conchalí',
      'Huechuraba',
      'Independencia',
      'Recoleta',
      'Cerro Navia',
      'Lo Prado',
      'Quinta Normal',
      'Otra'
    ],
    'Valdivia': [
      'Valdivia Centro',
      'Las Ánimas',
      'Collico',
      'Niebla',
      'Corral',
      'Los Lagos',
      'Futrono',
      'Mariquina',
      'Lanco',
      'Panguipulli',
      'Otra'
    ],
    'Villarrica': [
      'Villarrica Centro',
      'Pucón',
      'Curarrehue',
      'Lican Ray',
      'Coñaripe',
      'Otra'
    ],
    'Paine': ['Santiago', 'Paine']
  };

  @override
  void initState() {
    super.initState();
    _initializeRegionAndComuna();
  }

  void _initializeRegionAndComuna() {
    setState(() {
      if (widget.cityName == 'Paine') {
        _selectedRegion = 'Metropolitana';
        _selectedComuna = 'Santiago';
        _showComunaField = false;
      } else if (widget.cityName == 'Santiago') {
        _selectedRegion = 'Metropolitana';
        _selectedComuna = null;
        _showComunaField = false;
      } else if (widget.cityName == 'Valdivia' ||
          widget.cityName == 'Villarrica') {
        _selectedRegion = 'Los Ríos';
        _selectedComuna = null;
        _showComunaField = false;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _prayerRequestController.dispose();
    _observationsController.dispose();
    _comunaController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Determinar la comuna final
        String finalComuna;
        if (widget.cityName == 'Paine') {
          finalComuna = 'Santiago - Paine';
        } else if (_selectedComuna == 'Otra' &&
            _comunaController.text.isNotEmpty) {
          finalComuna = _comunaController.text.trim();
        } else {
          finalComuna = _selectedComuna ?? '';
        }

        await _firestoreService.addMember(
          cityName: widget.cityName,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          isNew: _isNew,
          region: _selectedRegion,
          comuna: finalComuna,
          prayerRequest: _prayerRequestController.text.trim(),
          observations: _observationsController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Miembro agregado exitosamente')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Miembro - ${widget.cityName}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox: ¿Es nuevo?
                    CheckboxListTile(
                      title: const Text('¿Es miembro nuevo?'),
                      value: _isNew,
                      onChanged: (value) {
                        setState(() {
                          _isNew = value ?? false;
                        });
                      },
                      activeColor: Colors.deepPurple,
                    ),

                    const SizedBox(height: 16),

                    // Campo: Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el nombre';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo: Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !value.contains('@')) {
                          return 'Ingrese un email válido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo: Teléfono
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el teléfono';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo: Dirección
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese la dirección';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo: Región (solo lectura)
                    TextFormField(
                      initialValue: _selectedRegion,
                      decoration: const InputDecoration(
                        labelText: 'Región',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    // Campo: Comuna
                    if (widget.cityName == 'Paine')
                      // Para Paine: mostrar campo fijo
                      TextFormField(
                        initialValue: 'Santiago - Paine',
                        decoration: const InputDecoration(
                          labelText: 'Comuna',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place),
                        ),
                        enabled: false,
                      )
                    else
                      // Para otras ciudades: dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedComuna,
                            decoration: const InputDecoration(
                              labelText: 'Comuna',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.place),
                            ),
                            items: _comunasByCiudad[widget.cityName]!
                                .map((comuna) => DropdownMenuItem(
                                      value: comuna,
                                      child: Text(comuna),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedComuna = value;
                                _showComunaField = (value == 'Otra');
                                if (!_showComunaField) {
                                  _comunaController.clear();
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione una comuna';
                              }
                              return null;
                            },
                          ),

                          // Campo de texto para "Otra" comuna
                          if (_showComunaField) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _comunaController,
                              decoration: const InputDecoration(
                                labelText: 'Especifique la comuna',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.edit_location),
                              ),
                              validator: (value) {
                                if (_selectedComuna == 'Otra' &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Por favor especifique la comuna';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Campo: Petición de oración (multilinea)
                    TextFormField(
                      controller: _prayerRequestController,
                      decoration: const InputDecoration(
                        labelText: 'Petición de oración',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite),
                        hintText: 'Escribe aquí las peticiones de oración...',
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),

                    const SizedBox(height: 16),

                    // Campo: Observaciones (multilinea)
                    TextFormField(
                      controller: _observationsController,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        hintText: 'Notas adicionales...',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),

                    const SizedBox(height: 24),

                    // Botón: Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMember,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text(
                          'Guardar Miembro',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
