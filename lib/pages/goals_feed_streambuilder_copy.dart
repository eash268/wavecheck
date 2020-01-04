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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: goalsRef.orderBy("timestamp", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Widget> goalsFormatted = new List<Widget>();
        for (var i = 0; i < snapshot.data.documents.length; i++) {
            var doc = snapshot.data.documents[i];
            goalsFormatted.add(GoalsItem.fromDocument(doc));
        }

        return Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Column(
            children: goalsFormatted,
          ),
        );
      },
    );
  }
}