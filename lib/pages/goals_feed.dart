import 'dart:math';

import 'package:WaveCheck/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/widgets/goal_tile.dart';
import 'package:WaveCheck/widgets/progress.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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
      (doc) => GoalsItem(doc.documentID, doc['goal_string'], doc['fk_user_id'], doc['urls'][0], doc['timestamp'], doc['completed'], doc['likes'], widget.currentUser)
    ).toList();

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
      //this.goals = goals.sublist(0, 10);
      this.goals = goals.sublist(0, min(goals.length, 15));
    });
  }

  refreshButton() {
    return GestureDetector(
      onTap: () {
        _getTimeline();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 5.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSo3MRSIByc3kKiuqhJg3bn9L8dh0sejw_iMuMGfH9RYh68XupN&s"),
              minRadius: 30.0,
            ),
          ),
          
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 5.0, top: 4.0),
            child: Text(
              "Everyone",
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[700]
              ),
            ),
          ),
          

        ],
      ),
    );
  }

  addNewMemberButton() {
    return GestureDetector(
      onTap: () {
        _getTimeline();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider("https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Ftransparent-round-icons%2F512%2Fadd.png&f=1&nofb=1"),
              minRadius: 30.0,
            ),
          ),
          
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 16.0, top: 4.0),
            child: Text(
              "Add Member",
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[700]
              ),
            ),
          ),
          

        ],
      ),
    );
  }

  everyoneButton() {
    return GestureDetector(
      onTap: () {
        _getTimeline();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 62,
            width: 62,
            margin: EdgeInsets.only(left: 18.0, right: 2.0),
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              border: Border.all(
                color: Colors.grey[700],
                width: 1
              ),
              borderRadius: BorderRadius.circular(1000),
            ),
            child: Icon(Icons.group, color: Colors.grey[700], size: 30,)
          ),
          
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 5.0, top: 2.0),
            child: Text(
              "All Goals",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  userProfilePicture(profileId, profileName, profilePic) {
    return GestureDetector(
      onTap: () {
        _filterPostsByUser(profileId);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 2.0),
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400],
                width: 1
              ),
              borderRadius: BorderRadius.circular(1000),
            ),
            child: CircleAvatar(
              //backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: CachedNetworkImageProvider(profilePic),
              minRadius: 28.0,
            ),
          ),
          
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 5.0, top: 2.0),
            child: Text(
              profileName.split(" ")[0],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.0,
                //color: Colors.black
              ),
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
          height: 14.0,
        ),
        FutureBuilder(
          future: usersRef.getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            
            List<Widget> allUsers = new List<Widget>();
            List<Widget> currentUser = new List<Widget>();
            List<Widget> otherUsers = new List<Widget>();

            for (var i = 0; i < snapshot.data.documents.length; i++) {
                var doc = snapshot.data.documents[i];
                if (widget.currentUser.id == doc.documentID) {
                  currentUser.add(userProfilePicture(doc.documentID, doc['first_name'] + ' ' + doc['last_name'], doc['profile_pic']));
                } else {
                  otherUsers.add(userProfilePicture(doc.documentID, doc['first_name'] + ' ' + doc['last_name'], doc['profile_pic']));
                }
            }

            allUsers.add(everyoneButton());
            List<Widget> users = allUsers + currentUser + otherUsers;
            //users.add(addNewMemberButton());

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: users
              )
            );
          },
        ),
        Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 75.0),
              child: EmptyListWidget(
                title: 'No Goals Yet',
                subTitle: 'Tap the + to get started.',
                image: 'assets/images/emptyImage.png',
                titleTextStyle: Theme.of(context).typography.dense.display1.copyWith(color: Color(0xff9da9c7)),
                subtitleTextStyle: Theme.of(context).typography.dense.body2.copyWith(color: Color(0xffabb8d6))
              ),
            ),
          ],
        ),
      ],
    );
  }

  buildTimeline() {
    if (goals == null) {
      return ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: circularProgress(),
          ),
        ]
      );
    } else if (goals.isEmpty) {
      return buildUsersRow(usersRef);
    } else {
      return ListView(
        children: <Widget>[
          SizedBox(
            height: 14.0,
          ),
          FutureBuilder(
            future: usersRef.getDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }

              List<Widget> allUsers = new List<Widget>();
              List<Widget> currentUser = new List<Widget>();
              List<Widget> otherUsers = new List<Widget>();

              for (var i = 0; i < snapshot.data.documents.length; i++) {
                  var doc = snapshot.data.documents[i];
                  if (widget.currentUser.id == doc.documentID) {
                    currentUser.add(userProfilePicture(doc.documentID, doc['first_name'] + ' ' + doc['last_name'], doc['profile_pic']));
                  } else {
                    otherUsers.add(userProfilePicture(doc.documentID, doc['first_name'] + ' ' + doc['last_name'], doc['profile_pic']));
                  }
              }

              allUsers.add(everyoneButton());
              List<Widget> users = allUsers + currentUser + otherUsers;

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
            margin: EdgeInsets.only(top: 10.0),
            //color: Theme.of(context).backgroundColor,
            color: Colors.grey[200],
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
    return LiquidPullToRefresh(
        onRefresh: () => _getTimeline(), 
        child: buildTimeline(),
        color: Colors.blue,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
    );

    // return buildTimeline();
  }
}