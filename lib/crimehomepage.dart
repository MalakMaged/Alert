import 'dart:html';
import 'package:crimebott/Add_post.dart';
import 'package:crimebott/dashboard.dart';
import 'package:crimebott/map.dart';
import 'package:crimebott/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:crimebott/profile_page.dart';

class CrimeAppHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red, // Set app bar color for profile page
      ),
      body: Center(
        child: Text(
          'This is the Profile Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}




// Home Page Widget
class CrimeHomePage extends StatefulWidget {
  const CrimeHomePage({Key? key}) : super(key: key);

  @override
  State<CrimeHomePage> createState() => _CrimeAppHomePageState();
}

class _CrimeAppHomePageState extends State<CrimeHomePage> {
  int _selectedIndex = 1; //New
  var pages = [ChatScreen(), DashboardPage(), ProfilePage(), MapPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALERT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20, // Set the font size
          ),
        ),
        centerTitle: true, //center my title
        backgroundColor: Colors.red, // Set app bar color to red
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red, // Set the selected button color to red
        unselectedItemColor:
            Colors.black, // Set the unselected button color to black
        onTap: _onItemTapped,
      ),
    );
  }
}













