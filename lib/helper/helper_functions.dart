// Helpful functions that can be used throughout the app

import 'package:intl/intl.dart';


// Convert a string value into a double value
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount?? 0;
}

// Format the double amount into a dollar value
String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: "en_US", symbol: "\$", decimalDigits: 2);
  return format.format(amount);
}