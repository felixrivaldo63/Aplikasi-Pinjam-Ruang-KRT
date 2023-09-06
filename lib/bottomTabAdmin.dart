import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_krt_ruang/pages_admin/home_admin.dart';
import 'package:flutter_krt_ruang/pages_user/info_ruang.dart';

class BottomTabAdmin extends StatefulWidget {
  const BottomTabAdmin({super.key});

  @override
  State<BottomTabAdmin> createState() => _BottomTabAdminState();
}

class _BottomTabAdminState extends State<BottomTabAdmin> {
  int _selectedIndex = 0;
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomeAdmin(),
    InfoRuang(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.grey.shade100,
          color: Colors.orange.shade400,
          animationDuration: Duration(milliseconds: 300),
          onTap: _navigateBottomBar,
          items: [
            Icon(
              Icons.home,
              color: Colors.purple.shade400,
            ),
            Icon(
              Icons.info,
              color: Colors.purple.shade400,
            ),
          ]),
    );
  }
}
