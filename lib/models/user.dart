import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String first_name;
  final String last_name;
  final String email;
  final String profile_pic;


  User({
    this.id,
    this.first_name,
    this.last_name,
    this.email,
    this.profile_pic
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      first_name: doc['first_name'],
      last_name: doc['last_name'],
      email: doc['email'],
      profile_pic: doc['profile_pic']
    );
  }

}