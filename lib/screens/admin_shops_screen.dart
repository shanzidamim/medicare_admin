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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadShops();
  }

  Future<void> loadShops() async {
    setState(() => loading = true);
    shops = await api.getShops();
    setState(() => loading = false);
  }

  Future<void> openForm([Map? shop]) async {
    final result = await showDialog<Map>(
      context: context,
      builder: (_) => _ShopForm(initial: shop),
    );
    if (result == null) return;
    if (shop == null) {
      await api.createShop(result);
    } else {
      await api.updateShop(shop['id'], result);
    }
    loadShops();
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
          headingRowColor:
          MaterialStateColor.resolveWith((_) => Colors.blue[100]!),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Shop Name')),
            DataColumn(label: Text('Division')),
            DataColumn(label: Text('Contact')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Actions')),
          ],
          rows: shops.map((s) {
            return DataRow(cells: [
              DataCell(Text('${s['id']}')),
              DataCell(Text(s['full_name'] ?? '')),
              DataCell(Text(s['division_name'] ?? '')),
              DataCell(Text(s['contact'] ?? '')),
              DataCell(Text(s['address'] ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () => openForm(s),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await api.deleteShop(s['id']);
                      loadShops();
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _ShopForm extends StatefulWidget {
  final Map? initial;
  const _ShopForm({this.initial});

  @override
  State<_ShopForm> createState() => _ShopFormState();
}

class _ShopFormState extends State<_ShopForm> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final division = TextEditingController();
  final address = TextEditingController();
  final timing = TextEditingController();
  final contact = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      name.text = widget.initial!['full_name'] ?? '';
      division.text = widget.initial!['division_name'] ?? '';
      address.text = widget.initial!['address'] ?? '';
      timing.text = widget.initial!['timing'] ?? '';
      contact.text = widget.initial!['contact'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Shop' : 'Edit Shop'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: division,
                decoration: const InputDecoration(labelText: 'Division Name'),
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
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'full_name': name.text.trim(),
              'division_name': division.text.trim(),
              'address': address.text.trim(),
              'timing': timing.text.trim(),
              'contact': contact.text.trim(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
