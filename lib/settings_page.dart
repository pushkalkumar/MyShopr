// settings_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'theme_notifier.dart'; // Import the global notifier
import 'navigation_page.dart'; // Import the NavigationPage widget

// Defining the settings page class
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return NavigationPage(
      // Assigns the current index value to make sure the navigation icon matches up with the correct page 
      currentIndex: 1,
      child: Scaffold(
        // Creates an app bar, and disables the back button, as well as sets basic properties 
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Settings', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        // Creates the body of the page, and puts a button to toggle the theme on it 
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Toggle the theme mode by notifying listeners when the value changes 
              // Whenever the current theme is light, the theme notifier value is dark, and the opposite occurs when it's dark
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            child: Text('Toggle Theme'),
          ),
        ),
      ),
    );
  }
}
