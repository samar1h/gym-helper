import 'package:flutter/material.dart';

class PageNotImplemented extends StatelessWidget {
  const PageNotImplemented({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: Text(
          "Page Not Found",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: "Go Back",
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(25),
        child: Text(
          "This page is not yet implemented. Press the button on top left to go back to previous page...",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
