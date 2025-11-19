// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../services/admin_api.dart';

class AdminShopsScreen extends StatefulWidget {
  const AdminShopsScreen({super.key});

  @override
  State<AdminShopsScreen> createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends State<AdminShopsScreen> {
  final api = AdminApi();
  List shops = [];
  List divisions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    setState(() => loading = true);

    try {
      shops = await api.getShops();
      divisions = await api.fetchDivisions();
    } catch (e) {
      debugPrint("❌ loadAll shops error: $e");
      shops = [];
      divisions = [];
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> openForm([Map? shop]) async {
    final result = await showDialog<Map>(
      context: context,
      builder: (_) => _ShopForm(initial: shop, divisions: divisions),
    );

    if (result == null) return;

    int shopId = 0;

    // ---- CREATE ----
    if (shop == null) {
      final res = await api.createShop(result);
      final newId = res.data?['id'] ?? 0;
      shopId = newId;
    }
    // ---- UPDATE ----
    else {
      await api.updateShop(shop['id'], result);
      shopId = shop['id'];
    }

    // ---- Upload Image (if selected) ----
    if (result['picked_image'] != null) {
      await api.uploadShopImage(shopId, result['picked_image']);
    }

    await loadAll();
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: DataTable(
          columnSpacing: 25,
          headingRowColor: WidgetStateProperty.all(Colors.blue[100]),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Shop Name')),
            DataColumn(label: Text('Division')),
            DataColumn(label: Text('Contact')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Actions')),
          ],
          rows: shops.map((s) {
            return DataRow(
              cells: [
                DataCell(Text('${s['id']}')),

                /// ---- IMAGE ----
                DataCell(
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: (s['image_url'] != null &&
                        s['image_url'].toString().isNotEmpty)
                        ? NetworkImage(s['image_url'])
                        : const AssetImage("assets/image/default_shop.png")
                    as ImageProvider,
                  ),
                ),

                /// ---- SHOP NAME ----
                DataCell(
                  SizedBox(
                    width: 140,
                    child: Text(
                      s['full_name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                DataCell(Text(s['division_name'] ?? '')),
                DataCell(Text(s['contact'] ?? '')),

                DataCell(
                  SizedBox(
                    width: 170,
                    child: Text(
                      s['address'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => openForm(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await api.deleteShop(s['id']);
                          loadAll();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ShopForm extends StatefulWidget {
  final Map? initial;
  final List divisions;

  const _ShopForm({this.initial, required this.divisions});

  @override
  State<_ShopForm> createState() => _ShopFormState();
}

class _ShopFormState extends State<_ShopForm> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final address = TextEditingController();
  final timing = TextEditingController();
  final contact = TextEditingController();

  String? divisionId;
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      name.text = widget.initial!['full_name'] ?? '';
      address.text = widget.initial!['address'] ?? '';
      timing.text = widget.initial!['timing'] ?? '';
      contact.text = widget.initial!['contact'] ?? '';
      divisionId = widget.initial!['division_id']?.toString();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => pickedImage = File(img.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Shop' : 'Edit Shop'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- IMAGE PICKER ----
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage!)
                            : (widget.initial?['image_url'] != null &&
                            widget.initial!['image_url']
                                .toString()
                                .isNotEmpty)
                            ? NetworkImage(widget.initial!['image_url'])
                            : const AssetImage(
                            "assets/image/default_shop.png")
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: pickImage,
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---- FORM FIELDS ----
                TextFormField(
                  controller: name,
                  decoration:
                  const InputDecoration(labelText: 'Shop Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField(
                  value: divisionId,
                  items: widget.divisions
                      .map((d) => DropdownMenuItem(
                    value: d['id'].toString(),
                    child: Text(d['division_name']),
                  ))
                      .toList(),
                  decoration:
                  const InputDecoration(labelText: 'Division'),
                  onChanged: (v) => setState(() => divisionId = v),
                  validator: (v) => v == null ? "Select division" : null,
                ),

                TextFormField(
                  controller: address,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: timing,
                  decoration: const InputDecoration(labelText: 'Timing'),
                ),
                TextFormField(
                  controller: contact,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
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
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(context, {
              'full_name': name.text.trim(),
              'division_id': int.parse(divisionId!),
              'address': address.text.trim(),
              'timing': timing.text.trim(),
              'contact': contact.text.trim(),
              'picked_image': pickedImage,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
