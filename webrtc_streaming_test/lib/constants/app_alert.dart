import 'package:flutter/material.dart';

Future<void> showAppAlert({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "OK",
  VoidCallback? onConfirm,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(confirmText),
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              if (onConfirm != null) onConfirm();
            },
          ),
        ],
      );
    },
  );
}