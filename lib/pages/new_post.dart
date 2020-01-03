import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final goalsRef = Firestore.instance.collection('goals');
final DateTime timestamp = DateTime.now();

class PostScreen extends StatefulWidget {
  final String userID;
  PostScreen(this.userID);

  @override
  _PostScreenState createState() => _PostScreenState(userID);
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();

  String userID;
  String goal;

  _PostScreenState(this.userID);

  submit() async {
    _formKey.currentState.save();
    print(goal);

    // 3) get username from create account, use it to make new user document in users collection
    goalsRef.document().setData({
      "fk_user_id": userID,
      "goal_string": goal,
      "timestamp": timestamp,
      "completed": false,
      "urls": [""],
      "likes": [""]
    });

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Create a Goal",
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),

            ],
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top:2.0, bottom: 20.0),
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    onSaved: (val) => goal = val,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Type any goal here...",
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    width: 1000,
                    padding: EdgeInsets.only(top: 16.0),
                    child: FlatButton(
                      color: const Color(0xFF46A4E4),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(15.0),
                      splashColor: Colors.blue[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: submit,
                      child: Text(
                        "Save and Share",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
            child: Text("Or choose from our list:", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          )

        ],
      ),
    );
  }
}