import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/pages/full_post.dart';
import 'package:WaveCheck/widgets/progress.dart';
import 'package:share/share.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

final goalsRef = Firestore.instance.collection('goals');
final usersRef = Firestore.instance.collection('users');

class GoalsItem extends StatefulWidget {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final Timestamp timestamp;
  final bool completed;
  final List goalLikes;
  final User currentUser;

  GoalsItem(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.timestamp, this.completed, this.goalLikes, this.currentUser);

  @override
  _GoalsItemState createState() => _GoalsItemState();
}

class _GoalsItemState extends State<GoalsItem> {
  _showJoinConfirm(goal) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Would you like to add \"$goal\" to your own goals?"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Yes I would"), 
                onPressed: () {}
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
      color: const Color(0xFF3cba54),
      //color: Colors.green,
      textColor: Colors.white,
      padding: EdgeInsets.all(12.0),
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Upload(widget.goalID, widget.currentUser)),
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
        color: const Color(0xFF2364CC),
        textColor: Colors.white,
        padding: EdgeInsets.all(12.0),
        splashColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
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
        margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
        child: _showCompleteButton(context),
      );
    } else if (!currentUserOwnsPost) {
      return Container(
        width: 1000,
        margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
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
        height: 250.0,
        width: double.infinity,
     ),
    );
  }

  _numLikes(likes) {
    int count = 0;
    if (likes == null) {
      count = -1;
    } else {
      likes.forEach((val) {
        if (val != '') {
          count += 1;
        }
      });
    }

    if (count == -1 || count == 0) {
      return "Like this goal:";
    } else if (count == 1) {
      return "1 person likes this goal";
    } else if (count > 1) {
      return count.toString() + " people like this goal";
    }

    return "";
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
            SimpleDialogOption(
              child: Text("Join this goal"), onPressed: () {
                _showJoinConfirm(goalName);
              }
            ),
            SimpleDialogOption(
              child: Text("Add a comment"), onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FullPost(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser)),
                );
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
          ],
        );
      });
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FullPost(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser)),
                  );
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 325,
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 0),
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
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(right: 16.0, top: 12.0),
                child: GestureDetector(
                  onTap: () {postActions(context, (widget.currentUser.id == widget.goalUserID), widget.goalName);},
                    child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 0.0, top: 0.0,),
            child: GoalUserHeader(widget.goalID, widget.goalUserID, widget.goalName, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FullPost(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser)),
              );
            },
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
                    Text(_numLikes(widget.goalLikes),
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
                      backgroundImage: NetworkImage("http://lorempixel.com/100/200/people/"),
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
            margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0, top: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                makeLikeButton(isActive: true),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FullPost(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser)),
                    );
                  },
                  child: makeCommentButton(),
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: usersRef.document(widget.goalUserID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FullPost(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser)),
              );
            },
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: NetworkImage(profilePic),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FullPost(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser)),
              );
            },
            child: Text(titleString, 
              style: TextStyle(
                fontSize: 14.0,
              )
            ),
          ),
          subtitle: Text(TimeAgo.getTimeAgo(widget.timestamp.millisecondsSinceEpoch),
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey[600]
            )
          ),
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
      child: GestureDetector(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.thumb_up, color: isActive ? const Color(0xFF2364CC) : Colors.grey, size: 18,),
            SizedBox(width: 5,),
            Text("Like", style: TextStyle(color: isActive ? const Color(0xFF2364CC) : Colors.grey[600]),)
          ],
        ),
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