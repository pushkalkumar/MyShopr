import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NewListTile extends StatelessWidget {
  // Defines various things for the tiles, and requires the title and trailing, as well as what to do when the edit and delete buttons are pressed
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  const NewListTile({super.key, required this.title, required this.trailing, required this.onEditPressed, required this.onDeletePressed});


  // Creates the slidable action, whenever a user slides from right to left on any of the items
  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        // Defines the edit and delete actions
        children: [
          SlidableAction(onPressed: onEditPressed, icon: Icons.edit, backgroundColor: Colors.grey,),
          SlidableAction(onPressed: onDeletePressed, icon: Icons.delete, backgroundColor: Colors.red,),
      ]
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(trailing),
      ),
      
      );
      
    }
}