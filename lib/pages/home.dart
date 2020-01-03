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
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      /*
      endDrawer: Drawer(
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
                      fit: BoxFit.cover,
                      image: NetworkImage('https://images.unsplash.com/photo-1511933801659-156d99ebea3e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80'),
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
      */
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
              Text("Today's Goals",
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
                color: Theme.of(context).primaryColor,
                size: 28.0,
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
              tooltip: 'More',
              icon: Icon(
                Icons.menu, 
                color: Colors.grey,
                size: 28.0,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
              },
            ),
            */
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          /*
          SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  width: 72.0,
                  height: 72.0,
                  margin: EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Friends",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Raleway'
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: NetworkImage(currentUser.profile_pic),
                        minRadius: 35.0,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),

          Container(
            width: 1000,
            margin: EdgeInsets.only(top: 16.0, left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FlatButton(
              color: Colors.transparent,
              padding: EdgeInsets.all(20.0),
              splashColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
                );
              },
              child: Text(
                "+ Add a New Goal",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[800]
                ),
              ),
            ),
          ),
          */
          GoalsFeed(currentUser),
          Container(
            margin: EdgeInsets.all(12.0),
            alignment: Alignment.center,
            child: Text(
              "WaveCheck © 2020",
              style: TextStyle(
                color: Colors.grey
              ),
            ),
          ),
          SizedBox(height: 20.0,)
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