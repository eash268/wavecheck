import 'package:flutter/material.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/goals_feed.dart';
import 'package:fluttershare/widgets/progress.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Open Side Menu',
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Text("Today",
          style: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Roboto',
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'My Account',
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile('test')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostScreen()),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.all(30.0),
                  child: Text("Add a new goal"),
                ),
              ),
              GestureDetector(
                onTap: () => {},
                child: Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.all(30.0),
                  child: Text("Complete a goal"),
                ),
              ),
            ],
          ),
          GoalsFeed(),
        ],
      ),
    );
  }
}






