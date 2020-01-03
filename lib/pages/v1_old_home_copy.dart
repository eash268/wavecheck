import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/new_post.dart';
import 'package:WaveCheck/pages/profile.dart';
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

  @override
  void initState() {
    super.initState();
    // detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false)
      .then((account) {
        handleSignIn(account);
      }).catchError((err) {
        print('Error signing in: $err');
      });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print('User signed in!: $account');
      createUserInFirestore();
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                (currentUser != null)? currentUser.first_name + ' ' + currentUser.last_name: "test",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage('https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fpavbca.com%2Fwalldb%2Foriginal%2F6%2F9%2Fb%2F198354.jpg&f=1&nofb=1'),
                  )
              )
            ),
            ListTile(
              leading: Icon(Icons.input),
              title: Text('Welcome'),
              onTap: () => {},
            ),
            ListTile(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile(currentUser.id, currentUser.first_name + ' ' + currentUser.last_name)),
                )
              },
              leading: Icon(Icons.verified_user),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => {Navigator.of(context).pop()},
            ),
            ListTile(
              leading: Icon(Icons.border_color),
              title: Text('Feedback'),
              onTap: () => {Navigator.of(context).pop()},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
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
                MaterialPageRoute(builder: (context) => Profile(currentUser.id, currentUser.first_name + ' ' + currentUser.last_name)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
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
          GoalsFeed(currentUser),
        ],
      ),
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
            color: Colors.blue,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 35.0, right: 35.0),
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
                color: Colors.blue,
                textColor: Colors.white,
                padding: EdgeInsets.all(15.0),
                splashColor: Colors.blue[200],
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
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