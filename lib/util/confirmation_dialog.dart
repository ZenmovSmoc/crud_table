import 'package:flutter/material.dart';

/// Displays a confirmation dialog to the user and returns their response.
///
/// The [showConfirmationDialog] function presents an [AlertDialog] with a confirmation message,
/// asking the user if they want to proceed with a specific action, such as deleting an item.
/// The dialog includes two buttons: "Confirm" and "Cancel".
///
/// - Tapping "Confirm" returns `true`, indicating the user confirmed the action.
/// - Tapping "Cancel" returns `false`, indicating the user cancelled the action.
///
/// The dialog prevents dismissal by tapping outside the dialog (`barrierDismissible: false`).
///
/// ### Parameters:
/// - [context]: The [BuildContext] in which the dialog is shown.
///
/// ### Returns:
/// A [Future] that resolves to a [bool?], where:
/// - `true` if the user confirmed the action.
/// - `false` if the user cancelled the action.
/// - `null` if the dialog was dismissed in an unusual way.
///
/// ### Example:
///
/// ```dart
/// bool? confirmed = await showConfirmationDialog(context);
/// if (confirmed == true) {
///   // Proceed with the action
/// } else {
///   // Cancel the action
/// }
/// ```
///
/// This function is useful for presenting critical decisions to users before proceeding with
/// potentially destructive actions.
Future<bool?> showConfirmationDialog(BuildContext context) async {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure want to delete this item?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
