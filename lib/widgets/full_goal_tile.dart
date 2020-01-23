import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/home.dart';
import 'package:WaveCheck/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/pages/full_post.dart';
import 'package:WaveCheck/widgets/progress.dart';
import 'package:share/share.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

final goalsRef = Firestore.instance.collection('goals');
final likesRef = Firestore.instance.collection('likes');
final usersRef = Firestore.instance.collection('users');
final joinsRef = Firestore.instance.collection('joins');

class FullGoalsItem extends StatefulWidget {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final Timestamp timestamp;
  final bool completed;
  final List goalLikes;
  final User currentUser;

  FullGoalsItem(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.timestamp, this.completed, this.goalLikes, this.currentUser);

  @override
  _FullGoalsItemState createState() => _FullGoalsItemState();
}

class _FullGoalsItemState extends State<FullGoalsItem> {
  String numLikes = "...";

  @override
  void initState() {
    super.initState();
  }

  _submitJoinGoal() async {
    await goalsRef.document().setData({
      "fk_user_id": widget.currentUser.id,
      "goal_string": widget.goalName,
      "timestamp": DateTime.now(),
      "completed": false,
      "urls": [""],
      "joins": [],
    });

    await joinsRef.document().setData({
      "fk_goal_id": widget.goalID,
      "fk_user_id": widget.currentUser.id,
      "profile_pic": widget.currentUser.profile_pic,
    });
 
    Navigator.pushAndRemoveUntil(context,   
      MaterialPageRoute(builder: (BuildContext context) => Home()),    
      ModalRoute.withName('/')
    ); 
  }

  _showJoinConfirm(goal) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Want to add \"$goal\" to your own goals?"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Yes I would"), 
                onPressed: () {
                  _submitJoinGoal();
                }
            ),
            SimpleDialogOption(
              child: Text("No, thanks"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  _showCompleteButton(context) {
    return FlatButton(
      color: Colors.blue,
      textColor: Colors.blue[50],
      padding: EdgeInsets.all(8.0),
      splashColor: Colors.blue[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      onPressed: () {
        Navigator.pushAndRemoveUntil(context,   
          MaterialPageRoute(builder: (BuildContext context) => Upload(widget.goalID, widget.currentUser)),    
          ModalRoute.withName('/')
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

  _showJoinButton(goalName) {
    var showJoinButton = true;
    if (showJoinButton) {
      return FlatButton(
        color: Colors.blue[50],
        textColor: Colors.blue,
        padding: EdgeInsets.only(top: 6, bottom: 8.0),
        splashColor: Colors.blue[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        onPressed: () {
          _showJoinConfirm(goalName);
        },
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
    } else {
      return SizedBox(height: 0,);
    }
  }

  handleActionButton(completed, currentUserOwnsPost, context, goalName) {
    if (currentUserOwnsPost && completed) {
      return SizedBox(height: 0,);
    } else if (currentUserOwnsPost && !completed) {
      return Container(
        width: 1000,
        margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 12.0),
        child: _showCompleteButton(context),
      );
    } else if (!currentUserOwnsPost) {
      return Container(
        width: 1000,
        margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 12.0),
        child: _showJoinButton(goalName),
      );
    }
  }

  _showImageSlider(img) {
    return Container(
    margin: EdgeInsets.only(bottom: 16.0),
    child: CachedNetworkImage(
        imageUrl: img,
        placeholder: (context, url) => CircularProgressIndicator(backgroundColor: Color(0xFF2364CC)),
        errorWidget: (context, url, error) => Icon(Icons.error),
        fit: BoxFit.fitWidth,
        width: double.infinity,
     ),
    );
  }

  joinRow() {
    return Row(
      children: <Widget>[
        Text("Joined By: ",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[700]
          ),
        ),
        FutureBuilder(
          future: joinsRef.where('fk_goal_id', isEqualTo: widget.goalID).getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("");
            }

            List<Widget> joiners = new List<Widget>();
            for (var i = 0; i < snapshot.data.documents.length; i++) {
                var doc = snapshot.data.documents[i];
                joiners.add(
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: CachedNetworkImageProvider(doc['profile_pic']),
                    radius: 9.0,
                  )
                );
            }
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: joiners
              )
            );
          },
        ),
        Text("",
          style: TextStyle(
            fontSize: 14.0,
            //fontStyle: FontStyle.italic,
            color: Colors.grey[700]
          ),
        ),
      ],
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        color: Colors.white,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(0.0),
        ),
        margin: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 0.0, top: 0.0,),
              child: GoalUserHeader(widget.goalID, widget.goalUserID, widget.goalName, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser),
            ),
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
                        margin: EdgeInsets.only(left: 16.0, top: 0.0, bottom: 12.0),
                        child: Container (
                          child: Text("" + widget.goalName, 
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
                /*
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 16.0, top: 0.0, bottom: 12.0),
                  child: GestureDetector(
                    onTap: () {postActions(context, (widget.currentUser.id == widget.goalUserID), widget.goalName);},
                      child: Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                  ),
                ),
                */
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: widget.completed? _showImageSlider(widget.goalImageURL) : Container(height: 0.0, width: 0.0, padding: EdgeInsets.all(0.0),),
            ),
            
            handleActionButton(widget.completed, (widget.currentUser.id == widget.goalUserID), context, widget.goalName),

            Container(
              width: 1000,
              padding: EdgeInsets.only(top: 0.0, left: 16.0, right: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      StreamBuilder(
                        stream: likesRef.where('fk_goal_id', isEqualTo: widget.goalID).snapshots(),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return circularProgress();
                          }

                          var count = snapshot.data.documents.length;
                          if (count == -1 || count == 0) {
                            numLikes = "0 people love this goal";
                          } else if (count == 1) {
                            numLikes = "1 person loves this goal";
                          } else if (count > 1) {
                            numLikes = count.toString() + " people love this goal";
                          }

                          return Text(numLikes,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[700]
                            ),
                          );

                        },
                      )
                    ],
                  ),
                  joinRow(),

                ],
              ),
            ),
            Divider(height: 0, color: Colors.grey[350], indent: 12.0, endIndent: 12.0,),
            SizedBox(height: 6.0,),
            Container(
              margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 6.0, top: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LikeButton(widget.goalID, widget.currentUser),
                  GestureDetector(
                    onTap: () {},
                    child: makeCommentButton(widget.goalID),
                  ),
                  GestureDetector(
                    onTap: () {
                      (widget.completed == true)? Share.share(widget.goalImageURL) : Share.share("Goal: " + widget.goalName);
                    },
                    child: makeShareButton(),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}

class GoalUserHeader extends StatefulWidget {
  final String goalID;
  final String goalUserID;
  final String goalName;
  final String goalImageURL;
  final Timestamp timestamp;
  final bool completed;
  final List goalLikes;
  final User currentUser;

  const GoalUserHeader(this.goalID, this.goalUserID,this.goalName, this.goalImageURL, this.timestamp, this.completed, this.goalLikes, this.currentUser);

  @override
  _GoalUserHeaderState createState() => _GoalUserHeaderState();
}

class _GoalUserHeaderState extends State<GoalUserHeader> {
  _submitJoinGoal(goal) async {
    await goalsRef.document().setData({
      "fk_user_id": widget.currentUser.id,
      "goal_string": goal,
      "timestamp": DateTime.now(),
      "completed": false,
      "urls": [""],
      "likes": [],
      "joins": [],
    });

    await joinsRef.document().setData({
      "fk_goal_id": widget.goalID,
      "fk_user_id": widget.currentUser.id,
      "profile_pic": widget.currentUser.profile_pic,
    });
 
    Navigator.pushAndRemoveUntil(context,   
      MaterialPageRoute(builder: (BuildContext context) => Home()),    
      ModalRoute.withName('/')
    ); 
  }

  _showJoinConfirm(goal) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Want to add \"$goal\" to your own goals?"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Yes I would"), 
                onPressed: () {
                  _submitJoinGoal(goal);
                }
            ),
            SimpleDialogOption(
              child: Text("No, thanks"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  deletePost() async {
    // delete post itself
    await goalsRef
        .document(widget.goalID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    Navigator.pushAndRemoveUntil(context,   
      MaterialPageRoute(builder: (BuildContext context) => Home()),    
      ModalRoute.withName('/')
    );
  }
  
  handleDeletePost(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Are you sure you want to delete this goal?"),
          children: <Widget>[
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                )),
            SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel')),
          ],
        );
      });
  }

  postActions(parentContext, currentUserOwnsPost, goalName) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Actions:"),
          children: <Widget>[
            !currentUserOwnsPost? SimpleDialogOption(
              child: Text("Join this goal"), onPressed: () {
                _showJoinConfirm(goalName);
              }
            ) : SimpleDialogOption(
              child: Text("Complete this goal"), onPressed: () {
                Navigator.pushAndRemoveUntil(context,   
                  MaterialPageRoute(builder: (BuildContext context) => Upload(widget.goalID, widget.currentUser)),    
                  ModalRoute.withName('/')
                );
              }
            ),
            SimpleDialogOption(
              child: Text("Add a comment"), onPressed: () {
                Navigator.pop(context);
              }
            ),
            currentUserOwnsPost? SimpleDialogOption(
                child: Text("Delete this goal",
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  handleDeletePost(context);
                }
            ) : SizedBox(height: 0,),
            SimpleDialogOption(
              child: Text("Cancel"), 
              onPressed: () {
                Navigator.pop(context);
              }
            ),
          ],
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: usersRef.document(widget.goalUserID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return 
          Container(
            padding: EdgeInsets.only(top: 0.0),
            margin: EdgeInsets.only(bottom: 12.0),
            child: linearProgress()
          );
        }

        var firstName = snapshot.data['first_name'];
        var lastName = snapshot.data['last_name'];
        var name = "$firstName $lastName";
        var profilePic = snapshot.data['profile_pic'];
        var titleString;

        if (widget.completed) {
          titleString = name + ' completed a goal!';
        } else {
          titleString = name + ' added a new goal';
        }

        return ListTile(
          leading: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              //backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: CachedNetworkImageProvider(profilePic),
            ),
          ),
          title: GestureDetector(
            onTap: () {},
            child: Text(titleString, 
              style: TextStyle(
                fontSize: 14.0,
              )
            ),
          ),
          subtitle: Text(TimeAgo.getTimeAgo(widget.timestamp.millisecondsSinceEpoch),
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey[700]
            )
          ),
          trailing: GestureDetector(
              onTap: () {postActions(context, (widget.currentUser.id == widget.goalUserID), widget.goalName);},
                child: Icon(
                Icons.more_horiz,
                color: Colors.grey[700],
              ),
            ),
          dense: false,
        );
      }
    );
  }
}

class LikeButton extends StatefulWidget {
  final String goalID;
  final User currentUser;

  LikeButton(this.goalID, this.currentUser);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  Color buttonColor = const Color(0xff616161);
  Color textColor = const Color(0xff616161);
  IconData icon = Icons.favorite_border;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (buttonColor == const Color(0xff616161) && textColor == const Color(0xff616161)) {
          setState(() {
            buttonColor = Color(0XFFF44336);
            textColor = Color(0XFFF44336);
            icon = Icons.favorite;

            likesRef.document(widget.goalID+widget.currentUser.id).setData({
              "fk_goal_id": widget.goalID,
              "fk_user_id": widget.currentUser.id,
              "timestamp": DateTime.now()
            });

          });    
        } else {
          setState(() {
            buttonColor = Color(0xff616161);
            textColor = Color(0xff616161);
            icon = Icons.favorite_border;

            likesRef.document(widget.goalID+widget.currentUser.id).delete();

          });    
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.grey[200]),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: buttonColor, size: 18,),
              SizedBox(width: 5,),
              Text("Love", style: TextStyle(color: textColor, fontSize: 14.0),)
            ],
          ),
        ),
      ),
    );
  }
}

Widget makeCommentButton(goalID) {  
  return StreamBuilder(
    stream: commentsRef.where('fk_goal_id', isEqualTo: goalID).snapshots(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            //border: Border.all(color: Colors.grey[200]),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 18),
                SizedBox(width: 5,),
                Text("Comment", style: TextStyle(color: Colors.grey[700], fontSize: 14.0),)
              ],
            ),
          ),
        );
      }

      var count = snapshot.data.documents.length;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.grey[200]),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 18),
              SizedBox(width: 5,),
              Text("Comment ($count)", style: TextStyle(color: Colors.grey[700], fontSize: 14.0),)
            ],
          ),
        ),
      );
    }
  );
}

Widget makeShareButton() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      //border: Border.all(color: Colors.grey[200]),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.share, color: Colors.grey[700], size: 18),
          SizedBox(width: 5,),
          Text("Share", style: TextStyle(color: Colors.grey[700], fontSize: 14.0),)
        ],
      ),
    ),
  );
}