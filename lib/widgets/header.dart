import 'package:flutter/material.dart';

AppBar header(context) {
  return AppBar(
    leading: IconButton(
      tooltip: 'Open Side Menu',
      icon: const Icon(Icons.menu),
      onPressed: () {},
    ),
    title: Text("Today",
      style: TextStyle(
        fontSize: 24.0,
        fontFamily: 'Roboto',
      ),
    ),
    actions: <Widget>[
      IconButton(
        tooltip: 'Previous choice',
        icon: const Icon(Icons.account_circle),
        onPressed: () {},
      ),
    ],
  );
}
