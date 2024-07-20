import 'package:isar/isar.dart';

// Generates the isar file, to enable local storage of data
part 'grocery.g.dart';
@Collection()
class Grocery {
  Id id = Isar.autoIncrement; 
  // declares the variables name, amount, and date for all of the groceries
  final String name;
  final double amount;
  final DateTime date;
  // makes them required fields
  Grocery({
   required this.name,
   required this.amount,
   required this.date,
  });
}