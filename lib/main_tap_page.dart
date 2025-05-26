import 'package:flutter/material.dart';
import 'package:flutter_project/todo_remote_page.dart';

import 'chat_page.dart';

class MainTapPage extends StatefulWidget {
  const MainTapPage({super.key});

  @override
  State<MainTapPage> createState() => _MainTapPageState();
}

class _MainTapPageState extends State<MainTapPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    TodoRemotePage(),
    ChatPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: '할 일'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: '채팅'
          ),
        ]
      ),
    );
  }
}
