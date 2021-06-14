import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context) async {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure want to delete this item?'),
        actions: <Widget>[
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}
