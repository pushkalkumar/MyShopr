import 'package:flutter/material.dart';

// Valuenotifier that holds the current theme in the app, and notifies the listeners when it is changed
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
