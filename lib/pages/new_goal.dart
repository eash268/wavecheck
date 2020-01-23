import 'package:WaveCheck/pages/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

    if (goal.replaceAll(new RegExp(r"\s+\b|\b\s"), "") != '') {
      await goalsRef.document().setData({
        "fk_user_id": widget.userID,
        "goal_string": goal,
        "timestamp": DateTime.now(),
        "completed": false,
        "urls": [""],
      });

      Navigator.pushAndRemoveUntil(context,   
        MaterialPageRoute(builder: (BuildContext context) => Home()),    
        ModalRoute.withName('/')
      ); 
    }
  }

  submitPreset(goal) async {
    await goalsRef.document().setData({
      "fk_user_id": widget.userID,
      "goal_string": goal,
      "timestamp": DateTime.now(),
      "completed": false,
      "urls": [""],
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
                  submitPreset(goal);
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

  newGoalSuggestions(text, subtext, img) {
    return GestureDetector(
      onTap: () {
        _showJoinConfirm(text);
      },
      child: Container(
        margin: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: CachedNetworkImageProvider(img),
                  radius: 28.0,
                ),
                title: Text(text),
                subtitle: Text(subtext),
              ),
            ],
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 1.0,
          iconTheme: IconThemeData(
            color: Colors.grey[700], //change your color here
          ),
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("New Goal",
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
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 28.0, bottom: 20.0),
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
                      color: Colors.blue,
                      textColor: Colors.blue[50],
                      splashColor: Colors.blue[100],
                      padding: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
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
            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
            child: Text("If you want to be happier...", 
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // happier
          newGoalSuggestions('Hang out with a positive person', 'POPULAR', 'https://images.unsplash.com/photo-1468277799724-b8ecdfa2cd7a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2250&q=80'),
          newGoalSuggestions('Buy something new', 'POPULAR', 'https://images.unsplash.com/photo-1556742502-ec7c0e9f34b1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80'),
          newGoalSuggestions('Walk a dog', 'POPULAR', 'https://images.unsplash.com/photo-1506242395783-cec2bda110e7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2250&q=80'),

















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
          newGoalSuggestions('Paint a picture', 'POPULAR', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fbebrainfit.com%2Fwp-content%2Fuploads%2F2016%2F05%2Fwoman-artist.jpg&f=1&nofb=1'),











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
          newGoalSuggestions('Go to the gym', 'POPULAR', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthoughtcatalog.files.wordpress.com%2F2015%2F02%2Fshutterstock_186988625.jpg&f=1&nofb=1'),
          newGoalSuggestions('Eat a protein-heavy meal', 'POPULAR', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fmedia.self.com%2Fphotos%2F57d70799f71ce8751f6b4332%2F4%3A3%2Fw_728%2Fchicken-pesto-recipe-9.jpg&f=1&nofb=1'),
          newGoalSuggestions('Drink a BIG glass of water', 'POPULAR', 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.regenerativemc.com%2Fwp-content%2Fuploads%2F2017%2F06%2Fbigstock-Glass-of-fresh-water-185236720-1024x681.jpg&f=1&nofb=1'),













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
          newGoalSuggestions('Dress in clothes that flatter me', 'NEW', 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fhypnozglam.com%2Fwp-content%2Fuploads%2F2015%2F04%2FIMG_2362.jpg&f=1&nofb=1'),























          
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
          newGoalSuggestions('Eat a piece of fruit or one serving of raw vegetables', 'NEW', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2F2.bp.blogspot.com%2F-nB-zcTyw6Xk%2FVDAFdVA4DBI%2FAAAAAAAAECk%2FSzVoAIfGSek%2Fs1600%2FP1350262.JPG&f=1&nofb=1'),
          newGoalSuggestions('Pack a healthy snack for myself', 'NEW', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fs-i.huffpost.com%2Fgen%2F2659642%2Fimages%2Fo-HEALTHY-SNACKS-FOR-WORK-facebook.jpg&f=1&nofb=1'),
          newGoalSuggestions('Split restaurant meals in half', 'NEW', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthecubanfoodblog.files.wordpress.com%2F2012%2F08%2Fbean-burger-cut-in-half1.jpg&f=1&nofb=1'),












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
          newGoalSuggestions('Drink a glass of (unsweetened) green tea', 'POPULAR', 'https://images.unsplash.com/photo-1499638673689-79a0b5115d87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1300&q=80'),
          newGoalSuggestions('Drink one tablespoon of apple cider vinegar', 'POPULAR', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.yummymummykitchen.com%2Fwp-content%2Fuploads%2F2018%2F11%2Fapple-cider-vinegar-drink-3.jpg&f=1&nofb=1'),
          newGoalSuggestions('Add a slice of lemon or lime to my water', 'NEW', 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.happyfoodstube.com%2Fwp-content%2Fuploads%2F2018%2F07%2Flemon-lime-cucumber-water-image.jpg&f=1&nofb=1'),











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
          newGoalSuggestions('Floss before bed', 'POPULAR', 'https://images.unsplash.com/photo-1559818469-fdf7a1ae929c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1596&q=80'),
          newGoalSuggestions('Walk for a half-hour', 'NEW', 'https://images.unsplash.com/photo-1519255122284-c3acd66be602?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1326&q=80'),
          newGoalSuggestions('Try a new healthy recipe', 'NEW', 'https://images.unsplash.com/photo-1571942676516-bcab84649e44?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2250&q=80'),




















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
          newGoalSuggestions('Read a book', 'POPULAR', 'https://images.unsplash.com/photo-1501622130202-7987a9ff9ec0?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1301&q=80'),
          newGoalSuggestions('Chew mint gum while studying', 'NEW', 'https://images.unsplash.com/photo-1527879831971-d95cde68cbf8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2250&q=80'),














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
          newGoalSuggestions('Take a picture of something inspiring', 'NEW', 'https://images.unsplash.com/photo-1528716321680-815a8cdb8cbe?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1310&q=80'),




















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
          newGoalSuggestions('Meditate for 15 minutes', 'NEW', 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1331&q=80'),
          newGoalSuggestions('Read a spiritual text (Bible, Vedas)', 'NEW', 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2250&q=80'),
          newGoalSuggestions('Look up at the stars', 'NEW', 'https://images.unsplash.com/photo-1464802686167-b939a6910659?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2233&q=80'),
          newGoalSuggestions('Enjoy a sunrise or sunset', 'NEW', 'https://images.unsplash.com/photo-1494548162494-384bba4ab999?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1600&q=80'),




        ],
      ),
    );
  }
}