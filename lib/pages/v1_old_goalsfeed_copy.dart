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
  final User currentUser;
  _GoalsFeedState(this.currentUser);

  @override
  void initState() {
    getGoals();
    // TODO: implement initState
    super.initState();
  }

  getGoals() {
    goalsRef.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        print(doc.data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: goalsRef.orderBy("timestamp", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Widget> goalsFormatted = new List<Widget>();
        for (var i = 0; i < snapshot.data.documents.length; i++) {
            var goalID = snapshot.data.documents[i].documentID;
            var goalName = snapshot.data.documents[i]['goal_string'];
            var userID = snapshot.data.documents[i]['fk_user_id'];
            var imageUrl = snapshot.data.documents[i]['urls'][0];
            var completed = snapshot.data.documents[i]['completed'];
            
            goalsFormatted.add(GoalsItem(goalID, goalName, userID, imageUrl, completed));

        }

        return Container(
          margin: EdgeInsets.only(top: 12.0),
          child: Column(
            children: goalsFormatted,
          ),
        );
      },
    );
  }
}