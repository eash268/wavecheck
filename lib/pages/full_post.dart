import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/widgets/full_goal_tile.dart';
import 'package:WaveCheck/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final commentsRef = Firestore.instance.collection('comments');

class FullPost extends StatefulWidget {
  final String goalID;
  final String goalName;
  final String goalUserID;
  final String goalImageURL;
  final Timestamp timestamp;
  final bool completed;
  final List goalLikes;
  final User currentUser;

  const FullPost(this.goalID, this.goalName, this.goalUserID, this.goalImageURL, this.timestamp, this.completed, this.goalLikes, this.currentUser);

  @override
  _FullPostState createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  final _formKey = GlobalKey<FormState>();
  String comment;

  @override
  void initState() {
    super.initState();
  }

  makeCommentRow(commentID, userID, comment, timestamp, likes, profilePic) {
    if (userID == widget.currentUser.id) {
      return Dismissible( 
        background: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.delete_outline, color: Colors.white,),
              Icon(Icons.delete_outline, color: Colors.white,)
            ],
          ),
        ),
        key: ValueKey(commentID),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(profilePic),
          ),
          title: Text(comment, 
            style: TextStyle(fontSize: 14.0),
          ),
          //trailing: Icon(Icons.favorite_border, color: Color(0xff9e9e9e),),
        ),
        onDismissed: (direction) {
          commentsRef.document(commentID).delete();
        },
      );
    } else {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(profilePic),
        ),
        title: Text(comment, 
          style: TextStyle(fontSize: 14.0),
        ),
        //trailing: Icon(Icons.favorite_border, color: Color(0xff9e9e9e)),
      );
    }
  }

  submit() {
    _formKey.currentState.save();

    if (comment.replaceAll(new RegExp(r"\s+\b|\b\s"), "") != '') {
      commentsRef.document().setData({
        "fk_goal_id": widget.goalID,
        "fk_user_id": widget.currentUser.id,
        "profile_pic": widget.currentUser.profile_pic,
        "comment": comment,
        "timestamp": DateTime.now(),
        "likes": 0
      });

      _formKey.currentState.reset();

    }
  }

  newCommentRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.currentUser.profile_pic),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.6666666,
            child: Form(
              key: _formKey,
              child: TextFormField(
                onSaved: (val) => comment = val,
                style: TextStyle(
                  fontSize: 14.0
                ),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: submit,
            child: Icon(Icons.send, color: Colors.grey[700],)
            //child: Text("Post", style: TextStyle(color: Colors.blue, fontSize: 16.0, fontWeight: FontWeight.bold),),
          )
        ],
      )
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.grey[700], //change your color here
        ),
        title: Text("",
          style: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 12.0),
            child: Column(
              children: <Widget>[
                FullGoalsItem(widget.goalID, widget.goalName, widget.goalUserID, widget.goalImageURL, widget.timestamp, widget.completed, widget.goalLikes, widget.currentUser),
                StreamBuilder(
                  stream: commentsRef.where('fk_goal_id', isEqualTo: widget.goalID).orderBy('timestamp', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    
                    if (snapshot.data == null) {
                      return SizedBox(height: 0,);
                    }

                    if (!snapshot.hasData) {
                      return circularProgress();
                    }

                    List<Widget> comments = new List<Widget>();
                    for (var i = 0; i < snapshot.data.documents.length; i++) {
                        var doc = snapshot.data.documents[i];
                        comments.add(makeCommentRow(doc.documentID, doc['fk_user_id'], doc['comment'], doc['timestamp'], doc['likes'], doc['profile_pic']));
                        comments.add(Divider());
                    }

                    return Column(
                      children: comments,
                    );
                  },
                ),
                newCommentRow(),
              ],
            ),
          )
        ],
      )
    );
  }
}
