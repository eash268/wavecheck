import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/progress.dart';

final goalsRef = Firestore.instance.collection('goals');

class GoalsFeed extends StatefulWidget {
  @override
  _GoalsFeedState createState() => _GoalsFeedState();
}

class _GoalsFeedState extends State<GoalsFeed> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: goalsRef.getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Widget> goalsFormatted = new List<Widget>();
        for (var i = 0; i < snapshot.data.documents.length; i++) {
            var name = snapshot.data.documents[i]['name'];
            var user = snapshot.data.documents[i]['user'];
            var imageUrl = snapshot.data.documents[i]['image_url'];
            var completed = snapshot.data.documents[i]['completed'];

            if (!completed) {
              goalsFormatted.add(new NewGoalsItem(name, user));
            } else {
              goalsFormatted.add(new CompletedGoalsItem(name, user, imageUrl));
            }
        }

        return Container(
          margin: EdgeInsets.only(top: 20.0),
          child: Column(
            children: goalsFormatted,
          ),
        );
      },
    );
  }
}

class NewGoalsItem extends StatelessWidget {
  final String goalName;
  final String goalUser;
  const NewGoalsItem(this.goalName, this.goalUser);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(goalUser)),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage('https://media.licdn.com/dms/image/C4D03AQHqlYvFlsSVLw/profile-displayphoto-shrink_200_200/0?e=1583366400&v=beta&t=UDhIz0Z1AZ8jti2SHuZ8n1572kdpPNN2lveA4VXkUTI'),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(goalUser + ' added a new goal:'),
                        Text('5 mins ago'),
                      ],
                    ) 
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: Text(goalName, 
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedGoalsItem extends StatelessWidget {
  final String goalName;
  final String goalUser;
  final String goalImageURL;
  const CompletedGoalsItem(this.goalName, this.goalUser, this.goalImageURL);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(goalUser)),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage('https://media.licdn.com/dms/image/C4D03AQHqlYvFlsSVLw/profile-displayphoto-shrink_200_200/0?e=1583366400&v=beta&t=UDhIz0Z1AZ8jti2SHuZ8n1572kdpPNN2lveA4VXkUTI'),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(goalUser + ' completed a goal!'),
                        Text('5 mins ago'),
                      ],
                    ) 
                  ),
                ],
              ),
            ),
          ),
          Image.network(
            goalImageURL,
            fit: BoxFit.fitWidth,
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: Text(goalName, 
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          

        ],
      ),
    );
  }
}