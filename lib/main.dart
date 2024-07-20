// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_shopr/database/grocery_database.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'theme_notifier.dart'; // Import the global notifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Waits for the database to initialize, then the app is run
  await GroceryDatabase.initialize();

  // Provides an instance of GroceryDatabase for the widget tree to use, allowing the changes made in the database to be reflected in the UI
  runApp(
    ChangeNotifierProvider(
      create: (context) => GroceryDatabase(),
      child: MainApp(), // Remove `const` to use the notifier
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          themeMode: mode,
          theme: ThemeData.light(), // Defining the light theme
          darkTheme: ThemeData.dark(), // Define the dark theme
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      },
    );
  }
}
