import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/widgets/goal_tile.dart';

final goalsRef = Firestore.instance.collection('goals');

class FullPost extends StatefulWidget {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final bool completed;

  const FullPost(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.completed);

  @override
  _FullPostState createState() => _FullPostState(goalID, goalName, goalUserID, goalImageURL, completed);
}

class _FullPostState extends State<FullPost> {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final bool completed;

  _FullPostState(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.completed);

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
        title: Text("Goal",
          style: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Roboto',
          ),
        ),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            child: Column(
              children: <Widget>[
                GoalsItem(goalID, goalName, goalUserID, goalImageURL, completed)
              ],
            ),
          )
        ],
      )
    );
  }
}
