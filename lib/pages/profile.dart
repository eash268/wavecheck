import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String userName;
  const Profile(this.userName);

  @override
  _ProfileState createState() => _ProfileState(userName);
}

class _ProfileState extends State<Profile> {
  final String userName;
  _ProfileState(this.userName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(userName,
          style: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Roboto',
          ),
        ),
        actions: <Widget>[],
      ),
      body: Text('profile'),
    );
  }
}
