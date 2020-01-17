import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:WaveCheck/models/user.dart';
import 'package:WaveCheck/pages/new_goal.dart';
import 'package:WaveCheck/pages/goals_feed.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share/share.dart';

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
          leading: null,
          automaticallyImplyLeading: false,
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 1.0,
          bottomOpacity: 0.0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: Text("Beta Testers Club",// + currentUser.first_name + ".",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              )
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
            
          ],
        ),
      ),
      body: GoalsFeed(currentUser),
      endDrawer: Drawer(
        elevation: 20.0,
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
                UserAccountsDrawerHeader(
                    accountName: Text(currentUser.first_name + ' ' + currentUser.last_name, 
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    accountEmail: Text(currentUser.email, 
                      style: TextStyle(
                        color: Colors.blue[50]
                      ),
                    ),
                    currentAccountPicture: Image.network(currentUser.profile_pic),
                    decoration: BoxDecoration(color: Colors.blue),
                ),
                ListTile(
                    leading: Icon(Icons.add_circle_outline),
                    title: Text('Add a New Goal'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
                      );
                    },
                ),
                Divider(
                    height: 2.0,
                ),
                ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('My Dashboard'),
                    onTap: () {
                        Navigator.pop(context);
                    },
                ),
                Divider(
                    height: 2.0,
                ),
                ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share GoalClub'),
                    onTap: () {
                        Navigator.pop(context);
                        Share.share("GoalClub is this super cool new app that allows you to track your daily goals with your friends. Check it out!");
                    },
                ),
                Divider(
                    height: 2.0,
                ),
                ListTile(
                    leading: Icon(Icons.close),
                    title: Text('Sign Out'),
                    onTap: () {
                        Navigator.pop(context);
                        logout();
                    },
                )
            ],
        )
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.srgbToLinearGamma()
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 250.0),
            Container(
              width: 1000,
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text('Setting goals is the first step in turning the invisible into the visible.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 40.0,
                  color: Colors.blue[50],
                ),
              ),
            ),
            SizedBox(height: 50.0),
            Container(
              width: 1000,
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: RaisedButton(
                textColor: Colors.blue[50],
                color: Colors.blue,
                padding: EdgeInsets.all(10.0),
                splashColor: Colors.blue[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
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