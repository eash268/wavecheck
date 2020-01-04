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
  List<dynamic> goals;
  List<dynamic> users;

  @override
  void initState() {
    super.initState();
    _getTimeline();
  }

  _filterPostsByUser(userID) async {
    QuerySnapshot snapshot = await goalsRef
        .where('fk_user_id', isEqualTo: userID)
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<GoalsItem> goals = snapshot.documents.map(
      (doc) => GoalsItem(doc.documentID, doc['goal_string'], doc['fk_user_id'], doc['urls'][0], doc['timestamp'], doc['completed'], doc['likes'], widget.currentUser)).toList();

    setState(() {
      this.goals = goals;
    });
  }

  _getTimeline() async {
    QuerySnapshot snapshot = await goalsRef
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<GoalsItem> goals = snapshot.documents.map(
      (doc) => GoalsItem(doc.documentID, doc['goal_string'], doc['fk_user_id'], doc['urls'][0], doc['timestamp'], doc['completed'], doc['likes'], widget.currentUser)).toList();

    setState(() {
      this.goals = goals;
    });
  }

  userProfilePicture(profile_id, profile_pic) {
    return GestureDetector(
      onTap: () {
        _filterPostsByUser(profile_id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: NetworkImage(profile_pic),
              minRadius: 30.0,
            ),
          ),

        ],
      ),
    );
  }

  buildUsersRow(usersRef) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 6.0,
        ),
        FutureBuilder(
          future: usersRef.getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            List<Widget> users = new List<Widget>();
            for (var i = 0; i < snapshot.data.documents.length; i++) {
                var doc = snapshot.data.documents[i];
                users.add(userProfilePicture(doc.documentID, doc['profile_pic']));
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: users
            );
          },
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

  buildTimeline() {
    if (goals == null) {
      return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: circularProgress(),
      );
    } else if (goals.isEmpty) {
      return buildUsersRow(usersRef);
    } else {
      return ListView(
        children: <Widget>[
          SizedBox(
            height: 6.0,
          ),
          FutureBuilder(
            future: usersRef.getDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }

              List<Widget> users = new List<Widget>();
              for (var i = 0; i < snapshot.data.documents.length; i++) {
                  var doc = snapshot.data.documents[i];
                  users.add(userProfilePicture(doc.documentID, doc['profile_pic']));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: users
                )
              );
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 12.0),
            color: Theme.of(context).backgroundColor,
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
        onRefresh: () => _getTimeline(), 
        child: buildTimeline()
    );
  }
}