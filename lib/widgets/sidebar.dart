import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const Sidebar({
    Key? key,
    required this.onItemSelected,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<Map<String, dynamic>> _menuItems = [
    {"icon": Icons.dashboard, "title": "Doctors"},
    {"icon": Icons.people, "title": "Users"},
    {"icon": Icons.local_hospital, "title": "Shops"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1565C0), // consistent deep blue
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Medicare Admin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white30, thickness: 0.6),
          const SizedBox(height: 10),

          // Sidebar menu list
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final bool isSelected = widget.selectedIndex == index;

                return InkWell(
                  onTap: () => widget.onItemSelected(index),
                  child: Container(
                    color: isSelected ? Colors.white24 : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          item["icon"],
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item["title"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
