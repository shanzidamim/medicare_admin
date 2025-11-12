import 'package:flutter/material.dart';
import '../services/admin_api.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final api = AdminApi();
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => loading = true);
    try {
      users = await api.getUsers();
    } catch (e) {
      debugPrint("Error loading users: $e");
    }
    setState(() => loading = false);
  }

  Future<void> deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await api.deleteUser(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
        loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: users.isEmpty
            ? const Center(child: Text("No users found"))
            : DataTable(
          headingRowColor: MaterialStateColor.resolveWith((_) => Colors.blue[100]!),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Mobile')),
            DataColumn(label: Text('User Type')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((u) {
            return DataRow(cells: [
              DataCell(Text('${u['user_id'] ?? ''}')),
              DataCell(Text('${u['first_name'] ?? ''} ${u['last_name'] ?? ''}')),
              DataCell(Text(u['email'] ?? '')),
              DataCell(Text(u['mobile'] ?? '')),
              DataCell(Text(_userTypeLabel(u['user_type']))),
              DataCell(Text(u['status'] == 1 ? "Active" : "Inactive")),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteUser(u['user_id']),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _userTypeLabel(dynamic t) {
    switch (t.toString()) {
      case '1':
        return 'User';
      case '2':
        return 'Doctor';
      case '3':
        return 'Shop';
      default:
        return 'Unknown';
    }
  }
}
