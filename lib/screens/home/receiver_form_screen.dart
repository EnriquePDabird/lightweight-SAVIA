import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class ReceiverFormScreen extends StatefulWidget {
  final String campaignId;
  final String userOrganization;
  final Map<String, dynamic>? existingReceiver;

  const ReceiverFormScreen({
    super.key,
    required this.campaignId,
    required this.userOrganization,
    this.existingReceiver,
  });

  @override
  State<ReceiverFormScreen> createState() => _ReceiverFormScreenState();
}

class _ReceiverFormScreenState extends State<ReceiverFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _groupController;
  late TextEditingController _orderController;

  String _selectedSex = 'Hombre';
  bool _isActive = true;

  // Location
  late TextEditingController _countryController;
  late TextEditingController _regionController;
  late TextEditingController _provinceController;
  late TextEditingController _municipalityController;
  late TextEditingController _districtController;

  // Coordinates
  late TextEditingController _latController;
  late TextEditingController _lngController;

  // Location Codes
  late TextEditingController _countryCodeController;
  late TextEditingController _admin1CodeController;
  late TextEditingController _admin2CodeController;
  late TextEditingController _admin3CodeController;
  late TextEditingController _admin4CodeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReceiver;

    // Basic Info
    _nameController = TextEditingController(text: r?['name'] ?? '');
    _phoneController = TextEditingController(text: r?['phone'] ?? '');
    _emailController = TextEditingController(text: r?['email'] ?? '');
    _groupController = TextEditingController(text: r?['group'] ?? '');
    _orderController = TextEditingController(
      text: (r?['order'] ?? 1).toString(),
    );

    _isActive = r?['active'] ?? true;

    String existingSex = r?['sex'] ?? 'Hombre';
    if (['Hombre', 'Mujer', 'Otro'].contains(existingSex)) {
      _selectedSex = existingSex;
    } else if (existingSex == 'Male') {
      _selectedSex = 'Hombre';
    } else if (existingSex == 'Female') {
      _selectedSex = 'Mujer';
    } else {
      _selectedSex = 'Otro';
    }

    // Location
    final loc = r?['location'] as Map<String, dynamic>?;
    _countryController = TextEditingController(
      text: loc?['country'] ?? r?['country'] ?? '',
    );
    _regionController = TextEditingController(
      text: loc?['region'] ?? r?['region'] ?? '',
    );
    _provinceController = TextEditingController(
      text: loc?['province'] ?? r?['province'] ?? '',
    );
    _municipalityController = TextEditingController(
      text: loc?['municipality'] ?? r?['municipality'] ?? '',
    );
    _districtController = TextEditingController(
      text: loc?['district'] ?? r?['district'] ?? '',
    );

    // Coordinates (coordenadas anidadas o latitud/longitud en raíz)
    final coords = loc?['coordenadas'] as Map<String, dynamic>?;
    String latText = coords?['lat']?.toString() ?? '';
    String lngText = coords?['lng']?.toString() ?? '';
    if (latText.isEmpty) latText = r?['latitud']?.toString() ?? '';
    if (lngText.isEmpty) lngText = r?['longitud']?.toString() ?? '';
    _latController = TextEditingController(text: latText);
    _lngController = TextEditingController(text: lngText);

    // Location Codes
    final codes = loc?['locationCodes'] as Map<String, dynamic>?;
    _countryCodeController = TextEditingController(
      text: codes?['country_code'] ?? '',
    );
    _admin1CodeController = TextEditingController(
      text: codes?['admin1_code'] ?? '',
    );
    _admin2CodeController = TextEditingController(
      text: codes?['admin2_code'] ?? '',
    );
    _admin3CodeController = TextEditingController(
      text: codes?['admin3_code'] ?? '',
    );
    _admin4CodeController = TextEditingController(
      text: codes?['admin4_code'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _groupController.dispose();
    _orderController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _provinceController.dispose();
    _municipalityController.dispose();
    _districtController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _countryCodeController.dispose();
    _admin1CodeController.dispose();
    _admin2CodeController.dispose();
    _admin3CodeController.dispose();
    _admin4CodeController.dispose();
    super.dispose();
  }

  Future<void> _saveReceiver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final latTrim = _latController.text.trim();
      final lngTrim = _lngController.text.trim();

      final data = {
        'active': _isActive,
        'campaignId': widget.campaignId,
        'country': _countryController.text.trim(),
        'district': _districtController.text.trim(),
        'email': _emailController.text.trim(),
        'group': _groupController.text.trim(),
        'latitud': latTrim,
        'longitud': lngTrim,
        'location': {
          'coordenadas': {'lat': latTrim, 'lng': lngTrim},
          'locationCodes': {
            'admin1_code': _admin1CodeController.text.trim(),
            'admin2_code': _admin2CodeController.text.trim(),
            'admin3_code': _admin3CodeController.text.trim(),
            'admin4_code': _admin4CodeController.text.trim(),
            'country_code': _countryCodeController.text.trim(),
          },
          'municipality': _municipalityController.text.trim(),
          'name': _nameController.text.trim(),
        },
        'municipality': _municipalityController.text.trim(),
        'name': _nameController.text.trim(),
        'order': int.tryParse(_orderController.text.trim()) ?? 1,
        'organization': widget.userOrganization,
        'phone': _phoneController.text.trim(),
        'province': _provinceController.text.trim(),
        'region': _regionController.text.trim(),
        'sex': _selectedSex,
      };

      if (widget.existingReceiver == null) {
        // Create
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirestoreService().createReceiver(data);
      } else {
        // Update
        await FirestoreService().updateReceiver(
          widget.existingReceiver!['docId'],
          data,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper widget for text fields
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, ingresa $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReceiver != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Receptor' : 'Añadir Receptor'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
                    // Switch de Activo
                    SwitchListTile(
                      title: const Text('Usuario Activo'),
                      value: _isActive,
                      onChanged: (val) {
                        setState(() {
                          _isActive = val;
                        });
                      },
                      activeThumbColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),

                    // --- Información General ---
                    const Text(
                      'Información General',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildTextField(
                      _nameController,
                      'Nombre',
                      isRequired: true,
                    ),
                    _buildTextField(
                      _phoneController,
                      'Teléfono',
                      isRequired: true,
                    ),
                    _buildTextField(_emailController, 'Correo Electrónico'),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedSex,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Hombre',
                            child: Text('Hombre'),
                          ),
                          DropdownMenuItem(
                            value: 'Mujer',
                            child: Text('Mujer'),
                          ),
                          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSex = val;
                            });
                          }
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Organización',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFFF3F4F6),
                        ),
                        child: Text(
                          widget.userOrganization,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    _buildTextField(_groupController, 'Grupo'),
                    _buildTextField(_orderController, 'Orden', isNumber: true),

                    const SizedBox(height: 24),

                    // --- Ubicación ---
                    const Text(
                      'Ubicación Geográfica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildTextField(_countryController, 'País'),
                    _buildTextField(_regionController, 'Región'),
                    _buildTextField(_provinceController, 'Provincia'),
                    _buildTextField(_municipalityController, 'Municipalidad'),
                    _buildTextField(_districtController, 'Distrito'),

                    const SizedBox(height: 24),

                    // --- Coordenadas ---
                    const Text(
                      'Coordenadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _latController,
                            'Latitud',
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _lngController,
                            'Longitud',
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Códigos de Ubicación ---
                    const Text(
                      'Códigos de Ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildTextField(_countryCodeController, 'Country Code'),
                    _buildTextField(_admin1CodeController, 'Admin 1 Code'),
                    _buildTextField(_admin2CodeController, 'Admin 2 Code'),
                    _buildTextField(_admin3CodeController, 'Admin 3 Code'),
                    _buildTextField(_admin4CodeController, 'Admin 4 Code'),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saveReceiver,
                        child: Text(
                          isEditing ? 'Guardar Cambios' : 'Crear Receptor',
                          style: const TextStyle(fontSize: 16),
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
