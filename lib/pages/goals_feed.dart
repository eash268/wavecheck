import 'package:WaveCheck/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empty_widget/empty_widget.dart';
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

  userProfilePicture(profile_id, profile_name, profile_pic) {
    return GestureDetector(
      onTap: () {
        _filterPostsByUser(profile_id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 5.0),
            child: CircleAvatar(
              //backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: CachedNetworkImageProvider(profile_pic),
              minRadius: 30.0,
            ),
          ),
          
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 5.0, top: 4.0),
            child: Text(
              profile_name.split(" ")[0],
              overflow: TextOverflow.ellipsis,
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

  buildUsersRow(usersRef) {
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: usersRef.getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                padding: EdgeInsets.only(top: 0.0),
                margin: EdgeInsets.only(bottom: 20.0),
                child: circularProgress()
              );
            }

            List<Widget> users = new List<Widget>();
            users.add(refreshButton());
            for (var i = 0; i < snapshot.data.documents.length; i++) {
                var doc = snapshot.data.documents[i];
                users.add(userProfilePicture(doc.documentID, doc['first_name'] + ' ' + doc['last_name'], doc['profile_pic']));
            }
            users.add(addNewMemberButton());

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: users
            );
          },
        ),
        Column(
          children: <Widget>[
            Container(
            margin: EdgeInsets.only(left: 15.0,
             right: 15.0, top: 100.0),
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
            height: 14.0,
          ),
          FutureBuilder(
            future: usersRef.getDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }

              List<Widget> users = new List<Widget>();
              users.add(refreshButton());
              for (var i = 0; i < snapshot.data.documents.length; i++) {
                  var doc = snapshot.data.documents[i];
                  users.add(userProfilePicture(doc.documentID, doc['first_name'] + ' ' + doc['last_name'], doc['profile_pic']));
              }
              users.add(addNewMemberButton());

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
    return RefreshIndicator(
        onRefresh: () => _getTimeline(), 
        child: buildTimeline()
    );
  }
}