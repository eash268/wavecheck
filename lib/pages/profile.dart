import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Profile extends StatefulWidget {
  final String userID;
  final String userName;
  const Profile(this.userID, this.userName);

  @override
  _ProfileState createState() => _ProfileState(userID, userName);
}

class _ProfileState extends State<Profile> {
  final String userID;
  final String userName;
  _ProfileState(this.userID, this.userName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
      body: FutureBuilder(
        future: usersRef.document(userID).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          var firstName = snapshot.data['first_name'];
          var lastName = snapshot.data['last_name'];
          var name = firstName + ' ' + lastName;
          var proPicURL = snapshot.data['profile_pic'];

          return ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(0.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(proPicURL),
                    ),
                    Text(name),
                  ],
                ),
              )
            ],
          );

        }
      ),
    );
  }
}
