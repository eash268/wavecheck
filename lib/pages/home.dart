import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/new_goal.dart';
import 'package:WaveCheck/pages/goals_feed.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final goalsRef = Firestore.instance.collection('goals');
final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      print("User signed in: $account");
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "first_name": user.displayName.split(' ')[0],
        "last_name": user.displayName.split(' ')[1],
        "profile_pic": user.photoUrl,
        "email": user.email,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0.0,
          bottomOpacity: 0.0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("It's goal time, " + currentUser.first_name + ".",
                style: TextStyle(
                  fontSize: 28.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),

            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Add New Goal',
              icon: Icon(
                Icons.add_circle_outline, 
                color: Colors.grey[600],
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
                );
              },
            ),
            /*
            IconButton(
              tooltip: 'Log Out',
              icon: Icon(
                Icons.close, 
                color: Colors.red[600],
                size: 30.0,
              ),
              onPressed: () {
                logout();
              },
            ),
            */
            
          ],
        ),
      ),
      body: GoalsFeed(currentUser)
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: Text('WaveCheck',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24.0,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 35.0, right: 35.0, bottom: 35.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Setting goals is the first step in turning the invisible into the visible.',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 30.0,
              ),
            ),
            Container(
              width: 1000,
              padding: EdgeInsets.only(top: 35.0),
              child: FlatButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                padding: EdgeInsets.all(15.0),
                splashColor: Colors.blue[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: login,
                child: Text(
                  "Sign in with Google",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}