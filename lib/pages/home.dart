import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
final tokensRef = Firestore.instance.collection('tokens');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

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

    _firebaseMessaging.getToken().then((token) {
      print("Token $token");
    });
    
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(message['notification']['body']),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text("Close"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          },
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print("Handle notification click.");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("Handle notification click.");
      },
    );
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      print("User signed in: $account");
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true)
      );

      _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
          print("Settings registered $settings");
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
        "profile_pic": (user.photoUrl != '' && user.photoUrl != null)? user.photoUrl : "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fc-sf.smule.com%2Fz0%2Faccount%2Ficon%2Fv4_defpic.png&f=1&nofb=1",
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

  _logToken() async {
    _firebaseMessaging.getToken().then((token) {
      print("Token $token");
      tokensRef.document().setData({
        "fk_user_id": currentUser.id,
        "user": currentUser.first_name + ' ' + currentUser.last_name,
        "token": token,
        "timestamp": timestamp
      });
    });
  }

  Scaffold buildAuthScreen() {
    
    _logToken();
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Beta Testers Club",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),

                    // Text(Welcome!,
                    //   overflow: TextOverflow.fade,
                    //   style: TextStyle(
                    //     fontSize: 14.0,
                    //     fontFamily: 'Roboto',
                    //   ),
                    // ),

                  ],
                ),
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Add New Goal',
              icon: Icon(
                Icons.add_circle_outline, 
                color: Colors.grey[700],
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostScreen(currentUser.id)),
                );
              },
            ),

            IconButton(
              tooltip: 'Menu',
              icon: Icon(
                Icons.menu, 
                color: Colors.grey[700],
                size: 30.0,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
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
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  fontSize: 20.0
                ),
              ),
              accountEmail: Text(currentUser.email, 
                style: TextStyle(
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(currentUser.profile_pic),
              ),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  colorFilter: ColorFilter.srgbToLinearGamma(),
                  image: AssetImage('assets/images/bg_drawer.jpg'),
                  fit: BoxFit.cover,
                )
              ),
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
              color: Colors.grey[350],
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
              color: Colors.grey[350],
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
              color: Colors.grey[350],
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
            image: AssetImage('assets/images/bg2.jpeg'),
            //image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1512850183-6d7990f42385?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80'),
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
                  color: Colors.white,
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