import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final goalsRef = Firestore.instance.collection('goals');
final DateTime timestamp = DateTime.now();

class PostScreen extends StatefulWidget {
  final String userID;
  PostScreen(this.userID);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  String goal;

  submit() async {
    _formKey.currentState.save();

    // 3) get username from create account, use it to make new user document in users collection
    await goalsRef.document().setData({
      "fk_user_id": widget.userID,
      "goal_string": goal,
      "timestamp": timestamp,
      "completed": false,
      "urls": [""],
      "likes": [],
      "joins": [],
    });

    Navigator.pop(context);
  }

  newGoalSuggestions(text, subtext, icon) {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image(
                image: AssetImage(icon),
              ),
              title: Text(text),
              subtitle: Text(subtext),
            ),
          ],
        ),
      )
    );
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
              Text("",
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
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top:20.0, bottom: 20.0),
            margin: EdgeInsets.only(top:12.0),
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
                      color: Theme.of(context).primaryColor,
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
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to be happier...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // happier
          newGoalSuggestions('Hang out with a positive person', 'POPULAR', 'assets/images/happiness.png'),
          newGoalSuggestions('Buy something new', 'POPULAR', 'assets/images/happiness.png'),
          newGoalSuggestions('Smile – even if you have to force it', 'NEW', 'assets/images/happiness.png'),
          newGoalSuggestions('Walk a dog', 'NEW', 'assets/images/happiness.png'),

















        Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to manage stress more effectively...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // stress reduction
          newGoalSuggestions('Listen to relaxing music', 'POPULAR', 'assets/images/stress.png'),
          newGoalSuggestions('Stretch different body parts', 'NEW', 'assets/images/stress.png'),
          newGoalSuggestions('Paint a picture', 'NEW', 'assets/images/stress.png'),











        Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to get in shape...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // lose weight
          newGoalSuggestions('Go to the gym', 'POPULAR', 'assets/images/shape.png'),
          newGoalSuggestions('Eat a protein-heavy meal', 'POPULAR', 'assets/images/shape.png'),
          newGoalSuggestions('Drink a BIG glass of water', 'POPULAR', 'assets/images/shape.png'),
          newGoalSuggestions('Park in the furthest parking spot', 'NEW', 'assets/images/shape.png'),













          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to be more confident...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Dress in clothes that flatter you', 'NEW', 'assets/images/confident.png'),























          
          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to eat more healthfully...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Eat one piece of fruit or one serving of raw vegetables', 'NEW', 'assets/images/eathealhy.png'),
          newGoalSuggestions('Pack a healthy snack for yourself', 'NEW', 'assets/images/eathealhy.png'),
          newGoalSuggestions('Split restaurant meals in half', 'NEW', 'assets/images/eathealhy.png'),












          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to rev up your metabolism...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Drink one tablespoon of apple cider vinegar', 'POPULAR', 'assets/images/metabolism.png'),
          newGoalSuggestions('Add a slice of lemon or lime to your water', 'NEW', 'assets/images/metabolism.png'),
          newGoalSuggestions('Drink a glass of (unsweetened) green tea', 'POPULAR', 'assets/images/metabolism.png'),
          newGoalSuggestions('Sprinkle cayenne pepper or cinnamon on food', 'NEW', 'assets/images/metabolism.png'),











          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to live longer...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Floss every night before bed', 'POPULAR', 'assets/images/livelonger.png'),
          newGoalSuggestions('Walk for a half-hour', 'NEW', 'assets/images/livelonger.png'),
          newGoalSuggestions('Try a new healthy recipe', 'NEW', 'assets/images/livelonger.png'),




















          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to be more productive...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Arrive at work fifteen minutes early', 'POPULAR', 'assets/images/productive.png'),
          newGoalSuggestions('Read a book', 'POPULAR', 'assets/images/productive.png'),
          newGoalSuggestions('Chew mint gum while studying', 'NEW', 'assets/images/productive.png'),














          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to explore your artistic side...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Take a picture of something inspiring', 'NEW', 'assets/images/artistic.png'),
          newGoalSuggestions('Watch a YouTube video about your field of art', 'NEW', 'assets/images/artistic.png'),



















          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to be more organized...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Drink a full glass of water before drinking alcohol', 'NEW', 'assets/images/organized.png'),
          newGoalSuggestions('Alternate club soda and alcoholic drinks', 'NEW', 'assets/images/organized.png'),
























          Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
            child: Text("If you want to become more spiritually-minded...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // confident
          newGoalSuggestions('Meditate for 15 minutes', 'NEW', 'assets/images/spiritual.png'),
          newGoalSuggestions('Read a spiritual text (Bible, Vedas)', 'NEW', 'assets/images/spiritual.png'),
          newGoalSuggestions('Look up at the stars', 'NEW', 'assets/images/spiritual.png'),
          newGoalSuggestions('Enjoy a sunrise or sunset', 'NEW', 'assets/images/spiritual.png'),




        ],
      ),
    );
  }
}