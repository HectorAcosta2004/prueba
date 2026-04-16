import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/home_screen.dart';
import 'package:flutter_application_1/components/login_screen.dart';
import 'package:flutter_application_1/push_service.dart';

class Wrapper_ejemplo extends StatefulWidget {
  const Wrapper_ejemplo({super.key});

  @override
  State<Wrapper_ejemplo> createState() => _Wrapper_ejemploState();
}

class _Wrapper_ejemploState extends State<Wrapper_ejemplo> {
  final List<Widget> _pages = [HomeScreen(), LoginScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BottomNavigationBarExample());
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const List<Widget> _pages = [HomeScreen(), LoginScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Agregamos un pequeño delay de 1 segundo para asegurar
    // que el motor de Flutter esté 100% listo
    Future.delayed(Duration(seconds: 1), () {
      PushNotificationService().initNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BottomNavigationBar Sample')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'login',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
