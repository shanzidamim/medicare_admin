import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'admin_appointments_screen.dart';
import 'admin_doctor_screen.dart';
import 'admin_shops_screen.dart';
import 'admin_users_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Screens for each menu item
  final List<Widget> _screens = const [
    AdminDoctorsScreen(),
    AdminUsersScreen(),
    AdminShopsScreen(),
    AdminAppointmentsScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ Replace NavigationRail with Sidebar
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          // ✅ Main content area
          Expanded(
            child: Container(
              color: const Color(0xfffdf5ff),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
