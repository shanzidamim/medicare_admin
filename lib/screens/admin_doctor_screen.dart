import 'dart:io';
import 'package:flutter/material.dart';
import '../services/admin_api.dart';
import 'package:image_picker/image_picker.dart';

import '../services/config.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  final api = AdminApi();
  List doctors = [];
  bool loading = true;

  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    setState(() => loading = true);
    try {
      doctors = await api.getDoctors();
    } catch (e) {
      debugPrint('Error loading doctors: $e');
    }
    setState(() => loading = false);
  }

  Future<void> openForm([Map? doc]) async {
    final result = await showDialog<Map>(
      context: context,
      builder: (_) => _DoctorForm(initial: doc),
    );
    if (result == null) return;

    try {
      if (doc == null) {
        // ✅ Create new doctor
        final createdId = await api.createDoctor(result);
        if (result['image_file'] != null) {
          await api.uploadDoctorImage(createdId, result['image_file']);
        }
      } else {
        // ✅ Update existing doctor
        await api.updateDoctor(doc['doctor_id'], result);
        if (result['image_file'] != null) {
          await api.uploadDoctorImage(doc['doctor_id'], result['image_file']);
        }
      }

      // ✅ Always reload doctors and refresh UI
      await loadDoctors();
      setState(() {});
    } catch (e) {
      debugPrint('Error saving doctor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _vertical,
            thumbVisibility: true,
            child: Scrollbar(
              controller: _horizontal,
              thumbVisibility: true,
              notificationPredicate: (notif) =>
              notif.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _vertical,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _horizontal,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minWidth: constraints.maxWidth),
                    child: Column(
                      children: [
                        // ======= Sticky Header =======
                        Container(
                          color: Colors.blue[100],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          child: const Row(
                            children: [
                              _HeaderCell('ID', width: 60),
                              _HeaderCell('Image', width: 80),
                              _HeaderCell('Name', width: 180),
                              _HeaderCell('Degrees', width: 200),
                              _HeaderCell('Years_Experience', width: 100),
                              _HeaderCell('Specialty', width: 180),
                              _HeaderCell('Category', width: 150),
                              _HeaderCell('Division', width: 150),
                              _HeaderCell('Clinic / Hospital',
                                  width: 200),
                              _HeaderCell('Address', width: 250),
                              _HeaderCell('Visit Days', width: 120),
                              _HeaderCell('Visiting Time', width: 140),
                              _HeaderCell('Contact', width: 150),
                              _HeaderCell('Actions', width: 120),
                            ],
                          ),
                        ),
                        // ======= Data Rows =======
                        ...doctors.map((d) {
                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black12)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                _Cell('${d['doctor_id']}', width: 60),
                                _ImageCell(d['image_url']),
                                _Cell(d['full_name'] ?? '', width: 180),
                                _Cell(d['degrees'] ?? '', width: 200),
                                _Cell(
                                    '${d['years_experience'] ?? ''} yrs',
                                    width: 100),
                                _Cell(d['specialty_detail'] ?? '',
                                    width: 180),
                                _Cell(d['category_name'] ?? '',
                                    width: 150),
                                _Cell(d['division_name'] ?? '',
                                    width: 150),
                                _Cell(d['clinic_or_hospital'] ?? '',
                                    width: 200),
                                _Cell(d['address'] ?? '', width: 250),
                                _Cell(d['visit_days'] ?? '',
                                    width: 120),
                                _Cell(d['visiting_time'] ?? '',
                                    width: 140),
                                _Cell(d['contact'] ?? '', width: 150),
                                _ActionCell(
                                  onEdit: () => openForm(d),
                                  onDelete: () async {
                                    await api
                                        .deleteDoctor(d['doctor_id']);
                                    loadDoctors();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Doctor Form Dialog
// ============================================================================

class _DoctorForm extends StatefulWidget {
  final Map? initial;
  const _DoctorForm({this.initial});

  @override
  State<_DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<_DoctorForm> {
  final _form = GlobalKey<FormState>();
  final name = TextEditingController();
  final degrees = TextEditingController();
  final years_experience = TextEditingController();
  final specialty = TextEditingController();
  final division = TextEditingController();
  final category = TextEditingController();
  final clinic = TextEditingController();
  final address = TextEditingController();
  final visitDays = TextEditingController();
  final visitTime = TextEditingController();
  final contact = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      name.text = widget.initial!['full_name'] ?? '';
      degrees.text = widget.initial!['degrees'] ?? ''; // ✅ fixed
      years_experience.text = widget.initial!['year_experience']?.toString() ?? '';
      specialty.text = widget.initial!['specialty_detail'] ?? '';
      division.text = widget.initial!['division_name'] ?? '';
      category.text = widget.initial!['category_name'] ?? '';
      clinic.text = widget.initial!['clinic_or_hospital'] ?? '';
      address.text = widget.initial!['address'] ?? '';
      visitDays.text = widget.initial!['visit_days'] ?? '';
      visitTime.text = widget.initial!['visiting_time'] ?? '';
      contact.text = widget.initial!['contact'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Doctor' : 'Edit Doctor'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue[200],
                    backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.add_a_photo, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                _input(name, 'Name', required: true),
                _input(degrees, 'Degrees'),
                _input(years_experience, 'Years of Experience'),
                _input(specialty, 'Specialty'),
                _input(category, 'Category'),
                _input(division, 'Division'),
                _input(clinic, 'Clinic / Hospital'),
                _input(address, 'Address'),
                _input(visitDays, 'Visit Days'),
                _input(visitTime, 'Visiting Time'),
                _input(contact, 'Contact'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(context, {
              'full_name': name.text.trim(),
              'degrees': degrees.text.trim(), // ✅ fixed
              'years_experience': years_experience.text.trim(), // ✅ fixed
              'specialty_detail': specialty.text.trim(),
              'division_name': division.text.trim(),
              'category_name': category.text.trim(),
              'clinic_or_hospital': clinic.text.trim(),
              'address': address.text.trim(),
              'visit_days': visitDays.text.trim(),
              'visiting_time': visitTime.text.trim(),
              'contact': contact.text.trim(),
              'image_file': _imageFile,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _input(TextEditingController c, String label,
      {bool required = false}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label),
      validator:
      required ? (v) => v!.isEmpty ? '$label is required' : null : null,
    );
  }
}

// ============================================================================
// Helper Widgets
// ============================================================================

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;
  const _HeaderCell(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style:
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final double width;
  const _Cell(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }
}

class _ImageCell extends StatelessWidget {
  final String? imageUrl;
  const _ImageCell(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 50,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network('$BASE_URL$imageUrl', fit: BoxFit.cover)

      )
          : const Icon(Icons.person, size: 40),
    );
  }
}

class _ActionCell extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ActionCell({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
