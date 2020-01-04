import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/upload.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/widgets/progress.dart';

final goalsRef = Firestore.instance.collection('goals');
final usersRef = Firestore.instance.collection('users');

class FullGoalsItem extends StatelessWidget {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final bool completed;
  final User currentUser;
  
  const FullGoalsItem(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.completed, this.currentUser);

  _showCompleteButton(context) {
    return FlatButton(
      color: const Color(0xFF3cba54),
      //color: Colors.green,
      textColor: Colors.white,
      padding: EdgeInsets.all(12.0),
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Upload(this.goalID, currentUser)),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Tap to Complete",
            style: TextStyle(
              fontSize: 14.0,
            ),
          )
        ],
      ),
    );
  }

  _showJoinButton() {
    return FlatButton(
      color: const Color(0xFF46A4E4),
      textColor: Colors.white,
      padding: EdgeInsets.all(12.0),
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Tap to Join",
            style: TextStyle(
              fontSize: 14.0,
            ),
          )
        ],
      ),
    );
  }

_showImageSlider(img) {
    if (img.length == 1) {
      var pics = [img, img];
      return CarouselSlider(
        height: 250.0,
        viewportFraction: 0.90,
        initialPage: 0,
        enableInfiniteScroll: false,
        reverse: false,
        pauseAutoPlayOnTouch: Duration(seconds: 10),
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
          items: pics.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.only(bottom: 18.0),
                  child: Image.network(
                    i,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    //height: 250.0,
                  ));
              },
            );
          }).toList(),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 18.0),
        child: Image.network(
          img,
          fit: BoxFit.cover,
          width: double.infinity,
          //height: 250.0,
        ));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
      ),
      margin: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 325,
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 16.0, top: 18.0),
                      child: Container (
                        child: Text("$goalName", 
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 16.0, top: 20.0),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 0.0, top: 0.0,),
            child: FullGoalUserHeader(goalID, goalUserID, completed),
          ),
          GestureDetector(
            onTap: () {},
            child: completed? _showImageSlider(goalImageURL) : Container(height: 0.0, width: 0.0, padding: EdgeInsets.all(0.0),),
          ),
          Container(
            width: 1000,
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0),
            child: completed ? _showJoinButton() : _showCompleteButton(context),
          ),
          Container(
            width: 1000,
            padding: EdgeInsets.only(top: 12.0, left: 18.0, right: 18.0, bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text("12 Likes",
                      style: TextStyle(
                        fontSize: 14.0,
                        //fontStyle: FontStyle.italic,
                        color: Colors.grey[600]
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("Joined By: ",
                      style: TextStyle(
                        fontSize: 14.0,
                        //fontStyle: FontStyle.italic,
                        color: Colors.grey[600]
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage("http://lorempixel.com/400/200/sports/Dummy-Text/"),
                      radius: 9.0,
                    ),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage("http://lorempixel.com/300/200/food/Dummy-Text/"),
                      radius: 9.0,
                    ),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage("http://lorempixel.com/200/200/people/"),
                      radius: 9.0,
                    ),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage("http://lorempixel.com/100/200/people/Dummy-Text/"),
                      radius: 9.0,
                    ),
                    Text(" +33",
                      style: TextStyle(
                        fontSize: 14.0,
                        //fontStyle: FontStyle.italic,
                        color: Colors.grey[600]
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0, top: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                makeLikeButton(isActive: true),
                makeCommentButton(),
                makeShareButton(),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class FullGoalUserHeader extends StatefulWidget {
  final String goalID;
  final String goalUserID;
  final bool completed;
  const FullGoalUserHeader(this.goalID, this.goalUserID, this.completed);

  @override
  _FullGoalUserHeaderState createState() => _FullGoalUserHeaderState(goalID, goalUserID, completed);
}

class _FullGoalUserHeaderState extends State<FullGoalUserHeader> {
  final String goalID;
  final String goalUserID;
  final bool completed;
  _FullGoalUserHeaderState(this.goalID, this.goalUserID, this.completed);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: usersRef.document(goalUserID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        var firstName = snapshot.data['first_name'];
        var lastName = snapshot.data['last_name'];
        var name = "$firstName $lastName";
        var profilePic = snapshot.data['profile_pic'];
        var titleString;

        if (completed) {
          titleString = name + ' completed a goal!';
        } else {
          titleString = name + ' added a new goal';
        }

        return ListTile(
          leading: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: NetworkImage(profilePic),
            ),
          ),
          title: GestureDetector(
            onTap: () {},
            child: Text(titleString),
          ),
          subtitle: Text('5 mins ago'),
          dense: false,
        );
      }
    );
  }
}

Widget makeLikeButton({isActive}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[200]),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.thumb_up, color: !isActive ? const Color(0xFF46A4E4) : Colors.grey, size: 18,),
          SizedBox(width: 5,),
          Text("Like", style: TextStyle(color: !isActive ? const Color(0xFF46A4E4) : Colors.grey[600]),)
        ],
      ),
    ),
  );
}

Widget makeCommentButton() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[200]),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.chat, color: Colors.grey, size: 18),
          SizedBox(width: 5,),
          Text("Comment", style: TextStyle(color: Colors.grey[600]),)
        ],
      ),
    ),
  );
}

Widget makeShareButton() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[200]),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.share, color: Colors.grey, size: 18),
          SizedBox(width: 5,),
          Text("Share", style: TextStyle(color: Colors.grey[600]),)
        ],
      ),
    ),
  );
}