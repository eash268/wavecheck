import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/new_post.dart';
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
    List<GoalsItem> goals =
        //snapshot.documents.map((doc) => Text(doc['goal_string'])).toList();
        snapshot.documents.map((doc) => GoalsItem.fromDocument(doc)).toList();
    setState(() {
      this.goals = goals;
    });
  }

  buildTimeline() {
    if (goals == null) {
      return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: circularProgress(),
      );
    } else if (goals.isEmpty) {
      return Text("No goals");
    } else {
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
                        backgroundImage: NetworkImage(currentUser.profile_pic),
                        minRadius: 30.0,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 12.0),
            color: Color(0XFFF7F6FB),
            //color: Colors.grey[200],
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Column(
                children: goals,
              ),
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

  @override
  Widget build(context) {
    return RefreshIndicator(
        onRefresh: () => getTimeline(), 
        child: buildTimeline()
    );
  }
}