import 'package:flutter/material.dart';

void featureNotImplemented(BuildContext context, {String? featureName}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        featureName != null
            ? '$featureName is not yet implemented'
            : 'This feature is not yet implemented',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange[700],
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
