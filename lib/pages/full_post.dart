import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/widgets/full_goal_tile.dart';
import 'package:WaveCheck/widgets/goal_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final goalsRef = Firestore.instance.collection('goals');

class FullPost extends StatefulWidget {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final Timestamp timestamp;
  final bool completed;
  final List goalLikes;
  final User currentUser;

  const FullPost(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.timestamp, this.completed, this.goalLikes, this.currentUser);

  @override
  _FullPostState createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text("",
          style: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 12.0),
            child: Column(
              children: <Widget>[
                GoalsItem(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser),
              ],
            ),
          )
        ],
      )
    );
  }
}
