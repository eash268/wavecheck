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
  _GoalsFeedState createState() => _GoalsFeedState();
}

class _GoalsFeedState extends State<GoalsFeed> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          SizedBox(
            height: 6.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 16.0),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: NetworkImage(widget.currentUser.profile_pic),
                        minRadius: 30.0,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
          Container(
            color: Color(0XFFF7F6FB),
            //color: Colors.grey[200],
            child: StreamBuilder(
              stream: goalsRef.orderBy("timestamp", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress();
                }

                List<Widget> goals = new List<Widget>();
                for (var i = 0; i < snapshot.data.documents.length; i++) {
                    var doc = snapshot.data.documents[i];
                    goals.add(GoalsItem(doc.documentID, doc['goal_string'], doc['fk_user_id'], doc['urls'][0], doc['timestamp'], doc['completed'], doc['likes'], widget.currentUser));
                }

                return Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: goals,
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            alignment: Alignment.center,
            child: Text(
              "WaveCheck © 2020",
              style: TextStyle(
                color: Colors.grey
              ),
            ),
          ),
          SizedBox(height: 20.0,)
        ],
      );
  }
}