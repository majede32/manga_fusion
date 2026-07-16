import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    // هنا سنضع روابط للصفحات (مثلاً صفحة المانجا، صفحة البحث، صفحة الإعدادات)
    Center(child: Text("المانجا المحدثة")),
    Center(child: Text("صفحة البحث")),
    Center(child: Text("الإعدادات")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "بحث"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "إعدادات"),
        ],
      ),
    );
  }
}
