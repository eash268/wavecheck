import 'package:WaveCheck/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/widgets/goal_tile.dart';
import 'package:WaveCheck/widgets/progress.dart';

final goalsRef = Firestore.instance.collection('goals');
final usersRef = Firestore.instance.collection('users');

class GoalsFeed extends StatefulWidget {
  final User currentUser;
  GoalsFeed(this.currentUser);

  @override
  _GoalsFeedState createState() => _GoalsFeedState(currentUser);
}

class _GoalsFeedState extends State<GoalsFeed> {
  User currentUser;
  _GoalsFeedState(this.currentUser);

  List<dynamic> goals;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await goalsRef
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<dynamic> goals =
        //snapshot.documents.map((doc) => Text(doc['goal_string'])).toList();
        snapshot.documents.map((doc) => GoalsItem.fromDocument(doc)).toList();
    setState(() {
      this.goals = goals;
    });
  }

  buildTimeline() {
    if (goals == null) {
      return circularProgress();
    } else if (goals.isEmpty) {
      return Text("No goals");
    } else {
      return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Column(
          children: goals,
        ),
      );
    }
  }

  @override
  Widget build(context) {
    return buildTimeline();
  }
}