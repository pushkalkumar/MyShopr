// importing necessary libraries

// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:my_shopr/models/grocery.dart';
import 'package:path_provider/path_provider.dart';

class GroceryDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Grocery> _allGroceries = [];

  // Setup

  // Initialize database, aids with storing the data
  static Future<void> initialize() async {
    // Getting the directory 
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([GrocerySchema], directory: dir.path);
  }

  // Getter Methods to read and get the data from the input fields

  List<Grocery> get allGrocery => _allGroceries;

  // Operations (CRUD - Create, Read, Update, Delete)

  // Create Operation - Add a new grocery 
  Future<void> createNewGrocery(Grocery newGrocery) async {
    // Add grocery to the database
    await isar.writeTxn(() => isar.grocerys.put(newGrocery));
    // Read the grocery from the database
    await readGroceries();
  }
  // Read Operation - Read the groceries that are already in the database
  Future<void> readGroceries() async {
    // get all existing expenses from a database
    List<Grocery> fetchedGroceries = await isar.grocerys.where().findAll();
    // send to local list, and display in user interface
    _allGroceries.clear();
    _allGroceries.addAll(fetchedGroceries);

    notifyListeners();
  }

  // Update Operation - Edit an expense in the database
  Future<void> updateGrocery(int id, Grocery updatedGrocery) async {
    // verify that the new and existing groceries have the same id
    updatedGrocery.id = id;
    // Update the value in the database
    await isar.writeTxn(() => isar.grocerys.put(updatedGrocery));
    // Read value from the database
    await readGroceries();

  }
  // Delete Operation - Delete an expense from the database
  Future<void> deleteGrocery(int id) async {
    // delete from database
    await isar.writeTxn(() => isar.grocerys.delete(id));

    // read from database
    await readGroceries();
  }


  // Helper Methods

}