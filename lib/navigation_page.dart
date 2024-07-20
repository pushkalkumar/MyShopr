// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables
// Importing all the necessary libraries and pages
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'help_page.dart';

// Wraps all of the children with a navigation bar
class NavigationPage extends StatefulWidget {
  final Widget child;
  // Storing the index of the current page 
  final int currentIndex;

  // Makes sure the the current index is a required value
  NavigationPage({required this.child, required this.currentIndex});

  @override
  // Creates the navigation page state
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  // Called every time a tab is selected on the google nav bar
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // Replaces the current route with a new route, allowing the user to navigate to their desired page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;

      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HelpPage()));
        break;
    }
  }

  // Creates a widget for the bottom navigation bar 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          // Creating the google nav bar 
          child: GNav(
            // Assigning properties such as colors, spacing, and calls the _onTabSelected function when the user clicks on a new page
            gap: 8,
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            onTabChange: _onTabSelected,
            padding: EdgeInsets.all(16),
            selectedIndex: _selectedIndex,
            // Creates the tabs, with the names of the tabs as well as icons to represent them
            tabs: const [
              GButton(icon: Icons.list, text: "Groceries"),
              GButton(icon: Icons.settings, text: "Settings"),
              GButton(icon: Icons.help, text: "Help"),
            ],
          ),
        ),
      ),
    );
  }
}
