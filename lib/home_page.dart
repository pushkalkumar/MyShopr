// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// Importing all the necessary libraries
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfwid;
import 'help_page.dart';
import 'settings_page.dart';
import 'package:my_shopr/components/list_tile.dart';
import 'package:my_shopr/database/grocery_database.dart';
import 'package:my_shopr/models/grocery.dart';

// Creating the pdf report of the groceries
Future<void> generatePdf(List<Grocery> groceries) async {
  final pdf = pdfwid.Document();

  pdf.addPage(
    pdfwid.Page(
      build: (pdfwid.Context context) => pdfwid.Column(
        crossAxisAlignment: pdfwid.CrossAxisAlignment.start,
        children: [
          // Styling and getting data from app, displaying it on the pdf
          pdfwid.Text('Grocery List', style: pdfwid.TextStyle(fontSize: 24)),
          pdfwid.SizedBox(height: 10),
          ...groceries.map(
            (grocery) => pdfwid.Row(
              mainAxisAlignment: pdfwid.MainAxisAlignment.spaceBetween,
              children: [
                pdfwid.Text(grocery.name),
                pdfwid.Text(grocery.amount.toStringAsFixed(2)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
// Generates pdf file and saves to temporary directory 
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/grocery_list.pdf');
  await file.writeAsBytes(await pdf.save());

  print('PDF saved to ${file.path}');
}

// Defining the home page class
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// Creating text editing controllers for both the text and amount, and initializing the value to 0
class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // read the groceries stored in the database and calculate the total amount
    Provider.of<GroceryDatabase>(context, listen: false).readGroceries();
    _calculateTotalAmount();
  }

  // Add the costs of all of the items entered together
  void _calculateTotalAmount() {
    final groceries = context.read<GroceryDatabase>().allGrocery;
    setState(() {
      totalAmount = groceries.fold(0, (sum, item) => sum + item.amount);
    });
  }

  // Format the amount 
  String formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Push the user to the correct page based on the nav bar icon that they click on
  void _onTabSelected(int ind) {
    switch (ind) {
      case 0:
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HelpPage()));
        break;
    }
  }

  // Creating the Dialog Box for new grocery items being added
  void openNewBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Grocery Item"),
        // creating the dimensions of dialogue box
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

          // Creating textfields for the name of the item as well as the amount that it cost  
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Item Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Cost"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        // Includes both cancel and save buttons, performing the corresponding actions
        actions: [
          _cancelButton(),
          _saveButton()
        ],
      ),
    );
  }

  // Creates a dialogue box for editing the entered values
  void openEditBox(Grocery grocery) {
    nameController.text = grocery.name;
    amountController.text = grocery.amount.toString();

    // Displaying the dialogue box, and defining basic information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Creating textfields for the name and amount, and sets them to the existing values
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Item Name"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: "Cost"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editGroceryButton(grocery)
        ],
      ),
    );
  }

  // Creates the delete box dialog for the user to delete an item from the list
  void openDeleteBox(Grocery grocery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete item?"),
        actions: [
          _cancelButton(),
          _deleteGroceryButton(grocery.id)
        ],
      ),
    );
  }

  // Creates the cancel button which exits from the dialogue box and clears the values in the name and amount controllers
  Widget _cancelButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: Text("Cancel"),
    );
  }
  // Creates the save button
  Widget _saveButton() {
    return TextButton(
      onPressed: () async {
        // Saves as long as both the name controller and amount controller isnt empty
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          // Creates a new item and saves the date and time at which it was created
          Grocery newGrocery = Grocery(
            name: nameController.text,
            amount: double.tryParse(amountController.text) ?? 0.0,
            date: DateTime.now(),
          );

          // Creates a new grocery in the isar database
          await context.read<GroceryDatabase>().createNewGrocery(newGrocery);

          // Clears both of the controllers and calculates the new amount
          nameController.clear();
          amountController.clear();
          _calculateTotalAmount();
        }
      },
      // Displays save text on the button
      child: Text("Save"),
    );
  }

  // Defines the edit button
  Widget _editGroceryButton(Grocery grocery) {
    return TextButton(
      onPressed: () async {
        // Check if at least one of the values have been changed
        if (nameController.text.isNotEmpty || amountController.text.isNotEmpty) {
          Navigator.pop(context);

          // Creates an updated grocery with the new values
          Grocery updatedGrocery = Grocery(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : grocery.name,
            amount: amountController.text.isNotEmpty
                ? double.tryParse(amountController.text) ?? grocery.amount
                : grocery.amount,
            date: DateTime.now(),
          );

          int existingID = grocery.id;
          // Sends the new grocery to the database, and recalculates the total amount
          await context
              .read<GroceryDatabase>()
              .updateGrocery(existingID, updatedGrocery);
          _calculateTotalAmount();
        }
      },
      // Displays save text
      child: Text("Save"),
    );
  }

  // Creates the delete button, and when it is clicked, the item is deleted and total amount is recalculated
  Widget _deleteGroceryButton(int id) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<GroceryDatabase>().deleteGrocery(id);
        _calculateTotalAmount();
      },
      child: Text("Delete"),
    );
  }

  // Exports the groceries into the pdf file
  Future<void> _exportToPdf() async {
    // Retrieves the groceries from the database, as well as defines the path where the pdf will  be saved
    final groceries = context.read<GroceryDatabase>().allGrocery;
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/grocery_list.pdf');
    // Generates the pdf using the groceries
    await generatePdf(groceries);

    // Opens the specified path on windows
    await Process.run('cmd', ['/c', 'start', file.path]);

    // Creates a pop up on the bottom of the screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generated and saved!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryDatabase>(
      builder: (context, value, child) => Scaffold(
        // Creates the app bar for the screen
        appBar: AppBar(
          // Preventing for the automatically generated back button from generating
          automaticallyImplyLeading: false,
          title: Text('Grocery Items',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true, // Centers the styled text in the appbar
          backgroundColor: Colors.grey[800], // Defines the background color of the appbar
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800], // Sets the background color of the app 
          ),
          child: Stack(
            // Creates the main UI for the screen
            children: [
              Column(
                children: [
                  // Container to display the total amount of all the groceries
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounds the corners of the container
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              // Displays the formatted total amount
                              formatAmount(totalAmount),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary, // Defines the color of the text box
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: value.allGrocery.length,
                      itemBuilder: (context, index) {
                        Grocery individualGrocery = value.allGrocery[index];
                        // Creates cards for each of the grocery items
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // ROunds the corners of the items
                          ),
                          child: NewListTile(
                            // Displays the name of the item as well as the price in the card
                            title: individualGrocery.name,
                            trailing: formatAmount(individualGrocery.amount),
                            // Defines the functions for what to do when the user clicks the delete and edit buttons
                            onEditPressed: (context) => openEditBox(individualGrocery),
                            onDeletePressed: (context) => openDeleteBox(individualGrocery),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Creates the pdf export button
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton(
                  // Defining the function to execute when the button is pressed
                  onPressed: _exportToPdf,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  // Defines the icon to use and styles it 
                  child: Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
              ),
              // Creates the add class button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  // Defines the function to be executed when the button is pressed
                  onPressed: openNewBox,
                  // Defines the color and style of the button
                  backgroundColor: Theme.of(context).colorScheme.secondary, 
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        // Creates the bottom navigation bar 
        bottomNavigationBar: Container(
          // Decorates and defines the Colors to be used in the navbar
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          // Creates a safe area and padding for the navbar
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey,
                hoverColor: Colors.grey,
                // Defines the gap, and various colors to be used
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                tabBackgroundColor: Colors.grey,
                color: Colors.white,
                // Defines the various different tabs in the app, the icons to be used, and the text
                tabs: [ 
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.settings, text: 'Settings'),
                  GButton(icon: Icons.help, text: 'Help'),
                ],
                // Defines the current index for the page, and what to do when the tab is changed
                selectedIndex: 0,
                onTabChange: _onTabSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
