import 'package:flutter/material.dart';
import '../services/admin_api.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final api = AdminApi();
  List appointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() => loading = true);
    try {
      appointments = await api.getAppointments();
    } catch (e) {
      debugPrint("Error loading appointments: $e");
    }
    setState(() => loading = false);
  }

  Future<void> deleteAppointment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await api.deleteAppointment(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment deleted successfully")),
        );
        loadAppointments();
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
        child: appointments.isEmpty
            ? const Center(child: Text("No appointments found"))
            : DataTable(
          headingRowColor: MaterialStateColor.resolveWith((_) => Colors.blue[100]!),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Doctor')),
            DataColumn(label: Text('Patient')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: appointments.map((a) {
            return DataRow(cells: [
              DataCell(Text('${a['id'] ?? ''}')),
              DataCell(Text(a['doctor_name'] ?? '')),
              DataCell(Text(a['user_name'] ?? '')),
              DataCell(Text(a['booking_date'] ?? '')),
              DataCell(Text(a['booking_time'] ?? '')),
              DataCell(Text(a['status'] ?? 'Pending')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteAppointment(a['id']),
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
